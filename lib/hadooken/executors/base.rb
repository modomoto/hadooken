module Hadooken
  module Executors
    class Base
      attr_reader :topics

      def initialize(topics)
        @topics = topics
        @consumer_lookup = {}
      end

      def shutdown
        true
      end

      private
        def dispatch(message)
          consumer_of(message.topic).perform(message.value, message.topic)
        rescue => e
          Util.capture_error(e, payload: message.value)
        ensure
          release_resources
        end

        def consumer_of(topic)
          @consumer_lookup[topic] ||= topics[topic.to_sym].constantize
        end

        def release_resources
          true
        end

    end
  end
end
