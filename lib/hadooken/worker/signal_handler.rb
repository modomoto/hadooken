module Hadooken
  class Worker
    class SignalHandler

      class << self
        def start
          Thread.new { handle_signals }
        end

        private
          def setup_signals
            reader, writer = IO.pipe

            %w(TERM QUIT SIGINT).each do |sig|
              trap(sig) { writer.puts sig }
            end

            reader
          end

          def handle_signals
            reader = setup_signals

            while !reader.closed? && IO.select([reader])
              Worker.shutdown
              reader.close
            end
          end

      end

    end
  end
end
