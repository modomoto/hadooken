require "active_support/all"
require "concurrent"
require "hadooken/version"
require "hadooken/cli"
require "hadooken/worker"
require "hadooken/configuration"
require "hadooken/util"
require "hadooken/utils/digest_store"
require "hadooken/consumer/callbacks"
require "hadooken/consumer/context"
require "hadooken/consumer/duplicated_entry"
require "hadooken/consumer/registery"
require "hadooken/consumer/utils"
require "hadooken/consumer"

module Hadooken

  # Configures hadooken via ruby script like so:
  #
  #   require "hadooken"
  #
  #   Hadooken.configure do |config|
  #     config.error_capturer = -> (error) { puts error.class }
  #     config.group_name     = "ConsumerGroupName"
  #   end
  def self.configure(&block)
    block.call(configuration) if const_defined?(:HADOOKEN)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

end
