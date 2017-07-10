require "kafka"

module Hadooken
  class Worker

    class << self
      attr_reader :index

      def run(index)
        @index = index
        @consumer_lookup = {}
        setup_helper_threads

        subscription.each_message do |message|
          Util.put_log("New message #{message.offset}", :debug)
          pool.post { dispatch(message) }
        end
      rescue => e
        Util.capture_error(e)
      end

      private
        def pool
          @pool ||= Concurrent::ThreadPoolExecutor.new(min_threads: 1,
                                                       max_threads: Hadooken.configuration.threads,
                                                       max_queue:   -1,
                                                       fallback_policy: :caller_runs)
        end

        def consumer_of(topic)
          @consumer_lookup[topic] ||= Hadooken.configuration.topics[topic.to_sym].constantize
        end

        def dispatch(message)
          consumer_of(message.topic).perform(message.value)
        rescue => e
          Util.capture_error(e)
          Util.put_log(e.message, :fatal)
        end

        def kafka
          @kafka ||= Kafka.new(seed_brokers: Hadooken.configuration.kafka[:brokers])
        end

        def subscription
          @subscription ||= begin
            consumer = kafka.consumer(group_id: Hadooken.configuration.group_name)
            Hadooken.configuration.topics.each do |topic_name, _|
              consumer.subscribe(topic_name.to_s)
            end
            consumer
          end
        end

        # This method creates 2 threads;
        # first one for handling signals for gracefull shutdown
        # second one for sending heartbeat messages to topic.
        def setup_helper_threads
          heartbeat_timer.execute
          Thread.new { handle_signals }
        end

        def heartbeat_timer
          @heartbeat_timer ||= begin
            timer_options = {
              execution_interval: Hadooken.configuration.heartbeat[:frequency],
              timeout_interval:   5
            }

            Concurrent::TimerTask.new(timer_options) { send_heartbeat_message }
          end
        end

        def send_heartbeat_message
          kafka.deliver_message(heartbeat_payload, topic: heartbeat_topic)
          Util.put_log("Heartbeat message has been sent")
        end

        def heartbeat_payload
          {
            data: {
              group_name: Hadooken.configuration.group_name,
              index:      index,
              message:    "I'm alive".freeze
            },
            meta: {
              uuid: SecureRandom.uuid,
              time: Time.now.rfc2822
            }
          }.to_json
        end

        def heartbeat_topic
          @heartbeat_topic ||= Hadooken.configuration.heartbeat[:topic].to_s
        end

        def setup_signals
          reader, writer = IO.pipe

          %w(TERM QUIT SIGINT).each do |sig|
            trap(sig) { writer.puts sig }
          end

          reader
        end

        def handle_signals
          reader = setup_signals

          while !reader.closed? && IO.select([reader])
            identity = index == -1 ? "master" : "#{index}. worker"
            Util.put_log("#{identity} is shutting down")
            subscription.stop
            heartbeat_timer.shutdown
            pool.shutdown
            reader.close
          end
        end

    end

  end
end
