# frozen_string_literal: true

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = 1 # Have to make sure the app is thread-safe
threads threads_count, threads_count

bind 'tcp://0.0.0.0'
port        ENV['PORT'] || 3000
environment (ENV['RACK_ENV'] || ENV.fetch('APP_ENV', nil)) || 'development'
