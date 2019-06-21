module Hadooken
  class Worker
    class ConsumerData

      class << self

        def notify
          Util.put_log("Sending registration information")
          Hadooken.kafka_client.deliver_message(payload, topic: topic)
        end

        private
          def payload
            {
              data: {
                group_name: Hadooken.configuration.group_name,
                name:       Worker.name,
                topics:     topic_data
              },
              meta: {
                name:    "registered_messages",
                version: "1.0",
                uuid:    SecureRandom.uuid,
                time:    Time.now.rfc2822
              }
            }.to_json
          end

          def topic_data
            Worker.configs[:topics].map do |topic, consumer|
              consumer_class = consumer.constantize

              # Someone try to register consumer which is
              # not subclass of our consumer in this case
              # we can not get the registered messages.
              if consumer_class <= Hadooken::Consumer
                messages = consumer_class.registered_messages

                { name: topic, messages: messages }
              end
            end.compact
          end

          def topic
            @topic ||= Hadooken.configuration.meta_topic.to_s
          end

      end

    end
  end
end
