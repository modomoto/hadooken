module Hadooken
  module Factories
    class Executor
      class << self
        def create(configs)
          if configs[:type] == :single_thread
            Executors::SingleThread.new(configs[:topics])
          else
            Executors::MultiThread.new(configs[:topics], configs[:threads])
          end
        end
      end
    end
  end
end
