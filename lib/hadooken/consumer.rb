module Hadooken
  class Consumer
    include Utils
    extend Registery
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
        Raven.capture_exception(e)
        put_log(e.class, :error)
      end

      # By overriding this method you can use the legacy
      # version of consumer. Which means dispatching can
      # be done manually.
      def consume(data, meta)
        message = meta[:name]
        handler = handler_of(message)

        if !handler
          return put_log("No handler found for #{message}", :info)
        end

        instance = new(data, meta)

        run_callbacks(instance, message)
        run_in_context(instance, handler)
      end

    end

  end
end
