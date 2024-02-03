# frozen_string_literal: true

require_relative '../environment'

ENV['APP_ENV'] ||= 'production'
ENV['RACK_ENV'] = ENV.fetch('APP_ENV', nil)

App.configure do |config|
  config.environment = 'production'
end
