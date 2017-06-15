module Hadooken
  class Consumer
    module Registery

      def registers
        @registers ||= {}
      end

      # Register message to either given handler method or
      # given block.
      def register(message_name, handler = nil, &block)
        raise 'Provide either handler method or block to consume message!' if !handler && !block

        registers[message_name.to_s] = (handler || block)
      end

    end
  end
end
