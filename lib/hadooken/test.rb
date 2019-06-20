require "hadooken/test/kafka_client"

module Hadooken
  self.configuration.environment = :test
  self.configuration.kafka[:client] = Test::KafkaClient
end
