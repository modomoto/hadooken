module Hadooken
  class Consumer
    module Utils
      extend ActiveSupport::Concern

      def check_dup!(data)
        self.class.check_dup!(data)
      end

      def put_log(message, severity)
        self.class.put_log(message, severity)
      end

      module ClassMethods
        def check_dup!(data)
          digest = OpenSSL::Digest::MD5.hexdigest(data.to_s)

          raise DuplicatedEntry.new(data) if !Hadooken::Util.register(digest)
        end

        def put_log(message, severity)
          Hadooken::Util.put_log(message, severity)
        end
      end

    end
  end
end
