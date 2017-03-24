require "hadooken/version"
require "hadooken/cli"
require "hadooken/worker"
require "hadooken/configuration"
require "hadooken/util"
require "concurrent"
require "active_support/all"

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
    block.call(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

end
