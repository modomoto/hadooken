module Hadooken
  class Consumer
    module Context

      def run_in_context(instance, handler)
        if handler.is_a?(Proc)
          instance.instance_exec(&handler)
        else
          instance.send(handler)
        end
      end

    end
  end
end
