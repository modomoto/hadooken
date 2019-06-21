module Hadooken
  module Executors
    class MultiThread < Base
      DEFAULT_THREAD_COUNT = 16

      def initialize(topics, threads)
        super(topics)
        @threads = threads
      end

      def execute(message)
        pool.post { dispatch(message) }
      end

      def shutdown
        pool.shutdown
      end

      private
        def pool
          @pool ||= Concurrent::ThreadPoolExecutor.new(min_threads: 1,
                                                       max_threads: threads,
                                                       max_queue:   -1,
                                                       fallback_policy: :caller_runs)
        end

        def threads
          @threads ||= DEFAULT_THREAD_COUNT
        end

        def release_resources
          if defined?(ActiveRecord) && ::ActiveRecord::Base.connected?
            ::ActiveRecord::Base.clear_active_connections!
          end
        end

    end
  end
end
