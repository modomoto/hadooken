module Hadooken
  class Worker
    class Heartbeat

      class << self
        def start
          timer.execute
        end

        def stop
          timer.shutdown
        end

        private
          def timer
            @timer ||= begin
              timer_options = {
                execution_interval: Hadooken.configuration.heartbeat[:frequency],
                timeout_interval:   5
              }

              Concurrent::TimerTask.new(timer_options) { send_message }
            end
          end

          def send_message
            Worker.kafka.deliver_message(payload, topic: heartbeat_topic)
            Util.put_log("Heartbeat message has been sent")
          end

          def payload
            {
              data: {
                group_name: Hadooken.configuration.group_name,
                index:      Worker.index,
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

      end

    end
  end
end
