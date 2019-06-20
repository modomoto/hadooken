module Hadooken
  module Errors
    class MissingTopic < RuntimeError
      def initialize(klass)
        super("Topic configuration is missing for #{klass}")
      end
    end
  end
end
