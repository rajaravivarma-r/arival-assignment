# frozen_string_literal: true

# File to setup common environment

require_relative 'init'

ENV['APP_ENV'] ||= 'development'

# constant to store Application configuration
class App
  extend Dry::Configurable

  setting :root_path
  setting :environment, default: ENV.fetch('APP_ENV', nil)
end

App.configure do |config|
  config.root_path = Pathname(__FILE__).parent.parent.expand_path
end
