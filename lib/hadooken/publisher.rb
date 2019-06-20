module Hadooken
  class Publisher
    DEFAULT_VERSION = "1.0"
    NAME_PATTERN = /(.+)(?:Publisher?)/

    class << self
      attr_writer :version, :message_name, :serializer, :topic

      def version
        @version ||= DEFAULT_VERSION
      end

      def message_name
        @message_name ||= infer_message_name
      end

      def serializer
        @serializer ||= infer_serializer
      end

      def topic
        @topic || raise(Errors::MissingTopic.new(self))
      end

      def meta
        { version: version, name: message_name, time: time }
      end

      def publish(object)
        new(object).publish
      end

      def produce(payload)
        Hadooken.producer.produce(payload, topic: topic)
      end

      private
        def infer_message_name
          publisher_name.underscore
        end

        def infer_serializer
          "#{publisher_name}Serializer".safe_constantize
        end

        def publisher_name
          name.match(NAME_PATTERN).captures.first
        end

        def time
          Time.now.rfc822
        end

    end

    attr_reader :object

    delegate :meta, :serializer, to: :"self.class"

    def initialize(object)
      @object = object
    end

    def publish
      self.class.produce(payload)
    end

    private
      def payload
        {
          meta: meta,
          data: data
        }.to_json
      end

      def data
        serializer.new(object).as_json
      end

  end
end
