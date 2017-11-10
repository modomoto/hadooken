module Hadooken
  class Consumer
    module Callbacks
      # Registers before_consume callback like AC callbacks to
      # run before consumer action.
      #
      # To call a method with `data` and the `meta` parameters for
      # all type of messages, you can register the callback like so:
      #
      #   before_consume :do_something_crucial
      #
      # Or instead of providing the method name, you can register
      # callback either with +Proc+ or with +lambda+ or even by
      # providing the block like so:
      #
      #   before_consume -> { puts meta }
      #   before_consume Proc.new { puts meta }
      #   before_consume do
      #     puts meta
      #   end
      #
      # It is also possible to register callbacks with options
      # `:except` and `:only` like so:
      #
      #   before_consume :do_something_crucial, only: [:order_paid]
      #   before_consume :do_another_thig, except: [:order_paid]
      #
      def before_consume(handler = nil, **options, &block)
        set_callback(:before, handler, options, &block)
      end

      # Registers after_consume callback like AC callbacks to
      # run after consumer action.
      #
      # All the parameters and options are same with before_consume
      # callback.
      def after_consume(handler = nil, **options, &block)
        set_callback(:after, handler, options, &block)
      end

      def set_callback(callback_type, handler, options, &block)
        raise 'Provide either handler method or block to consume message!' if !handler && !block

        callbacks[callback_type] << { handler: (handler || block), options: sanitize_options(options) }
      end

      def sanitize_options(options)
        sanitized_options = {}

        if options[:only]
          sanitized_options[:only] = transform_string_array(options[:only])
        end

        if options[:except]
          sanitized_options[:except] = transform_string_array(options[:except])
        end

        sanitized_options
      end

      # Transforms given value into array of strings
      def transform_string_array(value)
        (value.is_a?(Array) ? value : [value]).map(&:to_s)
      end

      def callbacks
        @callbacks ||= { before: [], after: [] }
      end

      def run_callbacks(type, instance, message_name)
        callbacks[type].each do |callback|
          if execute?(message_name, callback[:options])
            run_in_context(instance, callback[:handler])
          end
        end
      end

      def execute?(message_name, options)
        options.blank? ||
          (options[:except] && !options[:except].include?(message_name)) ||
          (options[:only] && options[:only].include?(message_name))
      end

    end
  end
end
