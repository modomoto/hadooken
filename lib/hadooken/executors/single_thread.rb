module Hadooken
  module Executors
    class SingleThread < Base
      def execute(message)
        dispatch(message)
      end
    end
  end
end
