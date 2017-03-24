require "kafka"

module Hadooken
  class Worker

    class << self
      attr_reader :index

      def run(index)
        @index = index

        Thread.new { handle_signals }

        subscription.each_message do |message|
          Kafka::Util.put_log("New message #{message.offset}", :debug)
          pool.post { Questionnaire::MessageConsumer.perform(message.value) }
        end
      rescue => e
        Util.capture_error(e)
        Util.put_log(e.message, :fatal)
      end

      private
        def pool
          @pool ||= Concurrent::ThreadPoolExecutor.new(min_threads: 1,
                                                       max_threads: Hadooken.configuration.threads,
                                                       max_queue:   -1,
                                                       fallback_policy: :caller_runs)
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
            pool.shutdown
            reader.close
          end
        end

    end

  end
end
