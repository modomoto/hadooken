module Hadooken
  module Utils
    class DigestStore
      DEFAULT_TTL = 120

      attr_reader :lookup, :ttl

      def initialize(**options)
        @lookup = {}
        @task   = Concurrent::TimerTask.new(options) { clear_lookup }
        @ttl    = options.fetch(:ttl, DEFAULT_TTL)
        @task.execute
      end

      def set(key)
        now  = Time.now
        time = lookup[key]

        return false if time && (now - time) < ttl

        lookup[key] = now
      end

      private
        def clear_lookup
          now = Time.now
          @lookup.delete_if{ |k, v| (now - v) > ttl }
          GC.start # It makes sense to call GC manually.
          Kafka::Util.put_log('Digest store vacuumed', :info)
        end

    end
  end
end
