module Hadooken
  module Factories
    class Worker
      class << self
        def create
          Thread.abort_on_exception = true
          inline_worker = workers_config.shift

          pids = workers_config.map do |worker_name, worker_config|
            fork { run_worker(worker_name, worker_config) }
          end

          run_worker(*inline_worker)
          pids << Process.pid
        end

        private
          def workers_config
            Hadooken.configuration.workers
          end

          def run_worker(worker_name, worker_config)
            Util.put_log("Running #{worker_name} worker")
            Hadooken::Worker.run(worker_name, worker_config)
          end

      end
    end
  end
end
