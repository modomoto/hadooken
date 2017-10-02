# To be able to use this module in rspec, at first you have to
# require both Hadooken and Hadooken::TestHelpers like so;
#
#   require 'hadooken'
#   require 'hadooken/testing/helpers'
#
# And then, set Hadooken environment to test like below;
#
#   Hadooken.configuration.environment = 'test'
#
# After you require the lib and set environment, the last thing
# you have to do is including `Hadooken::TestHelpers` into your
# favorite test framework.
#
# For rspec you can do this like so;
#
#   RSpec.configure do |config|
#     config.include Hadooken::TestHelpers
#   end
#
# To be able to run the consumer almost with the same behaviour
# as it runs in production, you should just call consumer method
# with the name of the topic and the JSON payload like so;
#
#   consume 'name-of-the-topic', 'JSON payload'
#
# Note: JSON payload must consist of both `meta` and `data`!
module Hadooken
  module TestHelpers

    # This method is necessary for initial configuration
    def self.included(klass)
      Hadooken::Worker.instance_variable_set('@consumer_lookup', {})
    end

    def consume(topic, payload)
      message = OpenStruct.new(topic: topic, value: payload)

      Hadooken::Worker.send(:dispatch, message)
    end

  end
end
