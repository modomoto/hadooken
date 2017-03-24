require "hadooken/version"
require "hadooken/cli"
require "hadooken/worker"
require "hadooken/configuration"
require "hadooken/util"
require "concurrent"
require "active_support/all"

module Hadooken

  def self.configure(&block)
    block.call(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

end
