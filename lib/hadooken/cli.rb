module Hadooken
  class CLI

    class << self
      def run
        puts "Running Hadooken(because hadouken is taken :|)"

        if Hadooken.configuration.daemon
          puts "Running as daemon"
          check_pid_file!
          Process.daemon(true, true)
        end

        require_env
        Thread.abort_on_exception = true

        pids = [Process.pid]
        (Hadooken.configuration.workers - 1).times do |index, worker|
          Util.put_log("Running #{index}. worker")

          pids << fork { Worker.run(index) }
        end

        fill_pid_file(pids) if Hadooken.configuration.daemon
        at_exit { remove_pid_file }

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
            require File.expand_path(Hadooken.configuration.require_env)
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

        def check_pid_file!
          if File.exist?(pid_file)
            puts "It seems like hadooken is already running!\nPlease check the pid file!"
            exit 1
          end
        end

        def fill_pid_file(pids)
          File.open(pid_file, 'w') do |f|
            pids.each { |pid| f.puts pid }
          end
        end

        def remove_pid_file
          File.delete(pid_file) if File.exist?(pid_file)
        end

        def pid_file
          Hadooken.configuration.pidfile
        end

    end

  end
end
