# For more information: https://github.com/puma/puma/blob/master/examples/config.rb
app_path = File.expand_path(File.dirname(File.dirname(__FILE__)))

pidfile "#{app_path}/tmp/pids/server.pid"

dev_env = 'development'
rails_env = ENV.fetch('RAILS_ENV', dev_env)
environment rails_env

port = ENV.fetch('PUMA_PORT', 3000)

state_path "#{app_path}/tmp/pids/puma.state"

# if rails_env == 'production'
#   stdout_redirect "#{app_path}/log/production.log", "#{app_path}/log/production_err.log", true
# end

bind "tcp://0.0.0.0:#{port}"

# === Cluster mode configs ===
puma_workers_from_env = ENV.fetch('PUMA_WORKERS', 1)
puma_min_threads_from_env = ENV.fetch('PUMA_MIN_THREADS', 0)
puma_max_threads_from_env = ENV.fetch('PUMA_MAX_THREADS', 5)

workers puma_workers_from_env
threads puma_min_threads_from_env,puma_max_threads_from_env

# Additional text to display in process listing
tag 'panoptes_api'
