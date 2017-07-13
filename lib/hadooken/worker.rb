module Hadooken
  class Worker

    class << self
      attr_reader :index

      def run(index)
        @running = true
        @index   = index
        @consumer_lookup = {}
        setup_helpers
        ConsumerData.notify

        subscription.each_message do |message|
          Util.put_log("New message #{message.offset}", :debug)
          pool.post { dispatch(message) }
        end
      rescue => e
        Util.capture_error(e)
        shutdown
      end

      # We are using this method in inner classes
      # therefore it has to be public.
      def kafka
        @kafka ||= Kafka.new(seed_brokers: Hadooken.configuration.kafka[:brokers])
      end

      def shutdown
        return if !@running

        Util.put_log("#{identity} is shutting down")
        Heartbeat.stop
        subscription.stop
        pool.shutdown
      ensure
        @running = false
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
        def setup_helpers
          Heartbeat.start
          SignalHandler.start
        end

        def identity
          index == -1 ? "master" : "#{index}. worker"
        end

    end

  end
end
