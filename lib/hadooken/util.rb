module Hadooken
  class Util

    class << self

      def register(digest)
        mutex.synchronize { digest_store.set(digest) }
      end

      # debug|info|warn|error|fatal
      def put_log(message, level = :info)
        mutex.synchronize { logger.send(level, message) }
      end

      def capture_error(e)
        error_capturer.call(e) if error_capturer
      end

      # error capturer should be a proc or lambda like:
      #   -> (e) { Raven.capture_exception(e) }
      def error_capturer
        @error_capturer ||= Hadooken.configuration.error_capturer
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      private
        def digest_store
          @digest_store ||= Utils::DigestStore.new(execution_interval: 60, timeout_interval: 5)
        end

        def mutex
          @mutex ||= Mutex.new
        end

    end

  end
end
