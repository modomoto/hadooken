module Hadooken
  module Test
    class KafkaClient
      def initialize(*); end

      def async_producer(*)
        AsyncProducer.new
      end

      def create_topic(name, **options)
        Topic.new(name, options)
      end

      class Topic
        attr_reader :name, :options

        def initialize(name, **options)
          @name = name
          @options = options
        end
      end

      class AsyncProducer
        class Envelope
          attr_reader :message, :topic

          def initialize(message, topic)
            @message = message
            @topic = topic
          end

          def version
            meta["version"]
          end

          def message_name
            meta["name"]
          end

          def data_as_json
            data.to_json
          end

          private
            def meta
              payload["meta"]
            end

            def data
              payload["data"]
            end

            def payload
              @payload ||= JSON.parse(message)
            end
        end

        def produce(message, topic:, **options)
          Envelope.new(message, topic)
        end

        def shutdown
          true
        end
      end
    end
  end
end
