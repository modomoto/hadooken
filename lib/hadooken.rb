require "kafka"
require "active_support/all"
require "concurrent"
require "hadooken/version"
require "hadooken/cli"
require "hadooken/worker/heartbeat"
require "hadooken/worker/signal_handler"
require "hadooken/worker/consumer_data"
require "hadooken/worker"
require "hadooken/configuration"
require "hadooken/util"
require "hadooken/utils/digest_store"
require "hadooken/consumer/callbacks"
require "hadooken/consumer/context"
require "hadooken/consumer/duplicated_entry"
require "hadooken/consumer/registry"
require "hadooken/consumer/utils"
require "hadooken/consumer"

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
    block.call(configuration) if const_defined?(:HADOOKEN)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.test_env?
    configuration.environment.to_sym == :test
  end

end
