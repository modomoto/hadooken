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

      def meta(computed_message_name)
        { version: version, name: computed_message_name, time: time }
      end

      def publish(object, **options)
        new(object, options).publish
      end

      def produce(payload, computed_topic)
        Hadooken.producer.produce(payload, topic: computed_topic)
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

    attr_reader :object, :options

    delegate :meta, :serializer, to: :"self.class"

    def initialize(object, **options)
      @object = object
      @options = options
    end

    def publish
      self.class.produce(payload, topic)
    end

    private
      def payload
        {
          meta: meta(message_name),
          data: data
        }.to_json
      end

      def data
        serializer.new(object).as_json
      end

      def topic
        self.class.topic.respond_to?(:call) ? instance_exec(&self.class.topic) : self.class.topic
      end

      def message_name
        self.class.message_name.respond_to?(:call) ? instance_exec(&self.class.message_name) : self.class.message_name
      end

  end
end
