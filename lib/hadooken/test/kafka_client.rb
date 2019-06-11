module Hadooken
  module Test
    class KafkaClient
      def initialize(*); end

      def async_producer(*)
        AsyncProducer.new
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

        def produce(message, topic:)
          Envelope.new(message, topic)
        end
      end
    end
  end
end
