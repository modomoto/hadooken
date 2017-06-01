module Hadooken
  class CLI

    class << self
      def start
        Hadooken.configuration.validate!
        require_env
        puts "Running Hadooken(because hadouken is taken :|)"

        if Hadooken.configuration.daemon
          puts "Running as daemon"
          check_pid_file!
          Process.daemon(true, false)
        end

        Thread.abort_on_exception = true

        pids = [Process.pid]
        (Hadooken.configuration.workers - 1).times do |index, worker|
          Util.put_log("Running #{index}. worker")

          pids << fork { Worker.run(index) }
        end

        fill_pid_file(pids) if Hadooken.configuration.daemon

        at_exit do
          Util.put_log("Bye bye.")
          remove_pid_file
        end

        Util.put_log("Running master worker")
        Worker.run(-1)
        Process.waitall
      end

      def stop
        if !File.exist?(pid_file)
          puts "It looks like hadooken is already stopped!"
          return
        end

        pids = File.read(pid_file).split("\n").join(' ')

        puts "Killing process(es) with ID #{pids}"

        # Instead of checking the process ID with `ps`
        # we need to explicitly check our PID file to
        # prevent race conditions!
        `
          kill #{pids}
          while [ -f #{pid_file} ]; do
            sleep 1
          done
        `

        puts "Hadooken has been stopped"
      end

      def restart
        stop
        start
      end

      private
        # Requires the environment which is specified by the user.
        # If the `require_env` is not specified than it tries to
        # require rails by default.
        def require_env
          ENV['RACK_ENV'] = ENV['RAILS_ENV'] = Hadooken.configuration.environment.to_s

          # Which means we want to require an environment
          # other than rails.
          if Hadooken.configuration.require_env
            require File.expand_path(Hadooken.configuration.require_env)
          else
            require "rails"

            if ::Rails::VERSION::MAJOR == 4
              require File.expand_path("config/application.rb")
              ::Rails::Application.initializer "hadooken.eager_load" do
                ::Rails.application.config.eager_load = true
              end
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
          File.delete(pid_file) if pid_file && File.exist?(pid_file)
        end

        def pid_file
          Hadooken.configuration.pidfile
        end

    end

  end
end
