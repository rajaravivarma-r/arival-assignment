# frozen_string_literal: true

require_relative '../environment'

ENV['APP_ENV'] ||= 'test'
ENV['RACK_ENV'] = ENV.fetch('APP_ENV', nil)

App.configure do |config|
  config.environment = 'test'
end
