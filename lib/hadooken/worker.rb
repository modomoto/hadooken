module Hadooken
  class Worker
    class << self
      attr_reader :name, :configs

      def run(name, configs)
        @running = true
        @name = name
        @configs = configs
        setup_helpers
        ConsumerData.notify

        subscription.each_message do |message|
          Util.put_log("New message #{message.offset}", :debug)
          executor.execute(message)
        end
      rescue => e
        Util.capture_error(e)
        shutdown
      end

      def shutdown
        return if !@running

        Util.put_log("#{name} worker is shutting down")
        Heartbeat.stop
        subscription.stop
        executor.shutdown
      ensure
        @running = false
      end

      private
        def subscription
          @subscription ||= begin
            consumer = Hadooken.kafka_client.consumer(group_id: group_id)
            configs[:topics].each do |topic_name, _|
              consumer.subscribe(topic_name.to_s)
            end
            consumer
          end
        end

        def group_id
          "#{Hadooken.configuration.group_name}/#{name}"
        end

        # This method creates 2 threads;
        # first one for handling signals for gracefull shutdown
        # second one for sending heartbeat messages to topic.
        def setup_helpers
          Heartbeat.start
          SignalHandler.start
        end

        def executor
          @executor ||= Factories::Executor.create(configs)
        end

    end

  end
end
