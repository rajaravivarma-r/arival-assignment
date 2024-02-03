# frozen_string_literal: true

# File to setup common environment

require_relative 'init'

ENV['APP_ENV'] ||= 'development'
ENV['RACK_ENV'] = ENV.fetch('APP_ENV', nil)

Dotenv.load(".env.#{ENV.fetch('APP_ENV', nil)}")
Bundler.require(:default, ENV.fetch('APP_ENV', nil))

# Used to load configuration from files residing in App.config.config_path
class ConfigFile
  # Thrown when the config file is not in the recognized file type
  class UnRecognizedFileType < StandardError
    def initialize(file_name)
      super("#{file_name} has unrecognized file type")
    end
  end

  attr_reader :file_name, :file_path, :file_extension

  def initialize(file_name:, config_path: App.config.config_path)
    @file_name = file_name
    @file_path = config_path.join(file_name)
    @file_extension = file_path.extname
  end

  def load_for(environment: App.config.environment)
    content = file_path.read
    configurations = if yaml_file?
                       load_yaml_content(content)
                     elsif erb_file?
                       load_erb_yaml_content(content)
                     else
                       raise UnRecognizedFileType, file_name
                     end
    configurations[environment]
  end

  private

  def yaml_file?
    ['.yaml', '.yml'].include?(file_extension)
  end

  def erb_file?
    ['.erb'].include?(file_extension)
  end

  def load_yaml_content(yaml_content)
    YAML.safe_load(yaml_content)
  end

  def load_erb_yaml_content(erb_content)
    yaml_content = ERB.new(erb_content).result(binding)
    load_yaml_content(yaml_content)
  end
end

# constant to store Application configuration
class App
  extend Dry::Configurable

  setting :root_path
  setting :config_path, constructor: proc { App.config.root_path.join('config') }
  setting :environment, default: ENV.fetch('APP_ENV', nil)

  setting :database_config do
    setting :adapter
    setting :max_connections
    setting :database
    setting :username
    setting :password
    setting :host
    setting :port
  end

  setting :redis do
    setting :password
    setting :host
    setting :port
    setting :database, default: 0
  end

  setting :mailjet do
    setting :api_key, default: ENV.fetch('MAILJET_API_KEY', nil)
    setting :secret_key, default: ENV.fetch('MAILJET_SECRET_KEY', nil)
  end

  setting :mailer do
    setting :from, default: ENV.fetch('EMAIL_SENDER', nil)
  end

  setting :secret do
    setting(
      :jwt_sign_private_key,
      default: OpenSSL::PKey::RSA.new(ENV.fetch('JWT_TOKEN_SIGN_PRIVATE_KEY', nil))
    )
    setting(
      :jwt_sign_public_key,
      default: OpenSSL::PKey::RSA.new(ENV.fetch('JWT_TOKEN_SIGN_PUBLIC_KEY', nil))
    )
    setting :jwt_sign_algorithm, default: 'RS256'
  end

  class << self
    # TODO: Replace this with the built-in update method
    def set_config(configurations:, config_name:)
      App.configure do |config|
        nested_config_object = config.send(config_name)
        configurations.each do |key, value|
          nested_config_object.send("#{key}=", value)
        end
      end
    end

    def load_current_environment!
      current_environment_file = App.config.config_path.join(
        'environments', App.config.environment
      )
      require current_environment_file.to_s
    end

    def load_initializers!
      # Loading all files under app/ directory by default
      # Add zeitwerk when autoloading becomes necessary
      App.config.config_path.join('initializers').glob('**/*.rb').sort.each do |f|
        require f
      end
    end

    def load_app_code!
      # Require the code in order where it is a dependency for other code
      App.config.root_path.glob('app/helpers/**/*.rb').sort.each { |f| require f }
      App.config.root_path.glob('app/middlewares/**/*.rb').sort.each { |f| require f }
      App.config.root_path.glob('app/**/*.rb').sort.each { |f| require f }
    end

    # Creates the following methods on the App class
    # * development_environment?
    # * test_environment?
    # * production_environment?
    %w[development test production].each do |environment|
      define_method("#{environment}_environment?") do
        App.config.environment == environment
      end
    end
  end
end

App.configure do |config|
  config.root_path = Pathname(__FILE__).parent.parent.expand_path

  database_configurations = ConfigFile.new(
    file_name: 'database.yaml.erb',
    config_path: App.config.config_path
  ).load_for(environment: config.environment)

  redis_configuration = ConfigFile.new(
    file_name: 'redis.yaml.erb',
    config_path: App.config.config_path
  ).load_for(environment: config.environment)

  App.set_config(
    configurations: database_configurations, config_name: :database_config
  )
  App.set_config(
    configurations: redis_configuration, config_name: :redis
  )
end

App.load_initializers!
