require "kafka"
require "active_support/all"
require "concurrent"
require "hadooken/cli"
require "hadooken/configuration"
require "hadooken/consumer/callbacks"
require "hadooken/consumer/context"
require "hadooken/consumer/duplicated_entry"
require "hadooken/consumer/registry"
require "hadooken/consumer/utils"
require "hadooken/consumer"
require "hadooken/errors/missing_topic"
require "hadooken/executors/base"
require "hadooken/executors/multi_thread"
require "hadooken/executors/single_thread"
require "hadooken/factories/worker"
require "hadooken/factories/executor"
require "hadooken/publisher"
require "hadooken/util"
require "hadooken/utils/digest_store"
require "hadooken/version"
require "hadooken/worker"
require "hadooken/worker/consumer_data"
require "hadooken/worker/heartbeat"
require "hadooken/worker/signal_handler"

module Hadooken

  # Configures hadooken via ruby script like so:
  #
  #   require "hadooken"
  #
  #   Hadooken.configure do |config|
  #     config.error_capturer = -> (error, context) { puts [error.class, context] }
  #     config.group_name     = "ConsumerGroupName"
  #   end
  def self.configure(&block)
    block.call(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.test_env?
    configuration.environment.to_sym == :test
  end

  def self.kafka_client
    @kafka_client ||= configuration.kafka[:client].new(seed_brokers: configuration.kafka[:brokers])
  end

  def self.producer
    @producer ||= kafka_client.async_producer(configuration.producer)
  end

end
