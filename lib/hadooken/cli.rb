module Hadooken
  class CLI

    class << self
      def run
        Process.daemon(true, true) if Hadooken.configuration.daemon
        require_env

        Util.put_log("Running KafkaDaemon")
        Thread.abort_on_exception = true

        pids = []
        (Hadooken.configuration.workers - 1).times do |index, worker|
          Util.put_log("Running #{index}. worker")

          pids << fork { Worker.run(index) }
        end

        Util.put_log("Running master worker")
        Worker.run(-1)
        Process.waitall
      end

      private
        # Requires the environment which is specified by the user.
        # If the `require_env` is not specified than it tries to
        # require rails by default.
        def require_env
          return false

          # Which means we want to require an environment
          # other than rails.
          if Hadooken.configuration.require_env

          else
            require 'rails'

            if ::Rails::VERSION::MAJOR == 4
              require File.expand_path("config/application.rb")
              require File.expand_path("config/environment.rb")
            else
              require File.expand_path("config/environment.rb")
            end
          end
        end

    end

  end
end
