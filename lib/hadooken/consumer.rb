module Hadooken
  class Consumer
    include Utils
    extend Registry
    extend Callbacks
    extend Context

    attr_reader :data, :meta

    def initialize(data, meta)
      @data = data
      @meta = meta
    end

    class << self
      # By overriding this method you can get the raw
      # json payload and work on your own.
      def perform(payload)
        time = Benchmark.realtime do
          hash = JSON.parse(payload).deep_symbolize_keys

          consume(hash[:data], hash[:meta])
        end

        m_seconds = '%.2f ms' % (time * 1000)

        put_log("Payload consumed in #{m_seconds}", :debug)
      rescue => e
        Util.capture_error(e, payload: payload)
      end

      # By overriding this method you can use the legacy
      # version of consumer. Which means dispatching can
      # be done manually.
      def consume(data, meta)
        handler = handler_of(meta[:name])

        if !handler
          return put_log("No handler found for #{meta[:name]}", :info)
        end

        run(handler, data, meta)
      end

      def run(handler, data, meta)
        instance = new(data, meta)

        run_callbacks(:before, instance, meta[:name])
        run_in_context(instance, handler)
        run_callbacks(:after, instance, meta[:name])
      end

    end

  end
end
