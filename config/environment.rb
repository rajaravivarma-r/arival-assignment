# frozen_string_literal: true

# File to setup common environment

require_relative 'init'

ENV['APP_ENV'] ||= 'development'

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
    setting :pool
    setting :database
    setting :username
    setting :password
  end

  class << self
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
  end
end

App.configure do |config|
  config.root_path = Pathname(__FILE__).parent.parent.expand_path

  database_configurations = ConfigFile.new(
    file_name: 'database.yaml.erb',
    config_path: App.config.config_path
  ).load_for(environment: config.environment)

  App.set_config(
    configurations: database_configurations, config_name: :database_config
  )
end

# Loading all files under app/ directory by default
# Add zeitwerk when autoloading becomes necessary
App.config.root_path.glob('app/**/*.rb').sort.each { |f| require f }
