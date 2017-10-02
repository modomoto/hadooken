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
