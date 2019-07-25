require "hadooken/test/kafka_client"

module Hadooken
  self.configuration.environment = :test
  self.configuration.kafka[:client] = Test::KafkaClient

  # To be able to use this module in your test suite, at first you should
  # require both Hadooken and Hadooken::Test modules like so;
  #
  #   require 'hadooken'
  #   require 'hadooken/test'
  #
  # After you requiring the library, you should do is including `Hadooken::Test`
  # into your favorite test framework.
  #
  # For rspec you can do this like so;
  #
  #   RSpec.configure do |config|
  #     config.include Hadooken::Test
  #   end
  #
  # To be able to run the consumer almost with the same behaviour as it runs in
  # production, you should just call consume method with the name of the topic
  # and the JSON payload like so;
  #
  #   consume 'name-of-the-topic', 'JSON payload'
  #
  # Note: JSON payload must consist of both `meta` and `data`!
  module Test
    # This method is necessary for initial configuration
    def self.included(klass)
      Hadooken::Worker.instance_variable_set('@consumer_lookup', {})
    end

    def consume(topic, payload)
      message = OpenStruct.new(topic: topic, value: payload)

      hadooken_executor.execute(message)
    end

    def hadooken_executor
      @hadooken_executor ||= Hadooken::Executor::SingleThread.new(hadooken_topics)
    end

    def hadooken_topics
      Hadooken.configuration.workers.each_with_object({}) do |worker, topics|
        topics.merge!(worker[:topics])
      end
    end
  end
end
