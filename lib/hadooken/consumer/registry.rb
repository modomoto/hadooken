module Hadooken
  class Consumer
    module Registry

      # Register message to either given handler method or
      # given block.
      def register(message_name, handler = nil, &block)
        raise 'Provide either handler method or block to consume message!' if !handler && !block

        registers[message_name.to_s] = (handler || block)
      end

      # Registers the rest of the messages to handler method
      # or given block. If you want to register all messages
      # to a handler, you can use this method alone.
      def register_rest(handler, &block)
        @register_rest ||= (handler || block)
      end

      def handler_of(message)
        handlers[message] ||= registers[message] || implicit_handler(message) || @register_rest
      end

      # Try to find public method with the name message.
      def implicit_handler(message)
        instance_methods(false).include?(message.to_sym) && message
      end

      def registers
        @registers ||= {}
      end

      def handlers
        @handlers ||= {}
      end

    end
  end
end
