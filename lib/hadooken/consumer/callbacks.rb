module Hadooken
  class Consumer
    module Callbacks
      # Register before_consume callbacks like AC callbacks
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
      #   before_consume -> (data, meta) { puts meta }
      #   before_consume Proc.new { |data, meta| puts meta }
      #   before_consume do |_, meta|
      #     puts meta
      #   end
      #
      # If you don't want to handle `data` and `meta` arguments,
      # use +Proc+ instead of using +lambda+.
      #
      # It is also possible to register callbacks with options
      # `:except` and `:only` like so:
      #
      #   before_consume :do_something_crucial, only: [:order_paid]
      #   before_consume :do_another_thig, except: [:order_paid]
      #
      def before_consume(handler = nil, **options, &block)
        raise 'Provide either handler method or block to consume message!' if !handler && !block

        before_callbacks << { handler: (handler || block), options: sanitize_options(options) }
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

      def before_callbacks
        @before_callbacks ||= []
      end

      def run_callbacks(instance, message_name)
        before_callbacks.each do |callback|
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
