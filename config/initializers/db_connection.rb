# frozen_string_literal: true

# Handles database specific things
class DatabaseConnection < SimpleDelegator
  class << self
    attr_reader :connection

    # WARNING: Not thread-safe. But okay, since it is a initialization code
    # rubocop:disable Naming/MemoizedInstanceVariableName
    def establish!(
      database_config: App.config.database_config,
      logger: Logger.new('log/db.log')
    )
      @connection ||= new(logger:, database_config:).connect
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName

    def database_exists?(database_name)
      res = connection.execute(
        "SELECT 1 FROM pg_database WHERE datname = '#{database_name}'"
      )
      res == 1
    end

    def create_database!(database_name)
      connection.execute("CREATE DATABASE #{database_name}")
    end

    def database_url
      connection.database_url
    end

    def migrations_path
      App.config.root_path.join('db/migrations')
    end

    def schema_file_path
      App.config.root_path.join('db/schema.rb')
    end
  end

  attr_reader :logger, :database_config

  def initialize(logger:, database_config:)
    @logger = logger
    @database_config = database_config
  end

  def connect
    return @connection if defined?(@connection)

    @connection = Sequel.connect(
      database_url,
      max_connections: database_config.max_connections,
      logger:
    )
    __setobj__(@connection)
    self
  end

  def database_url
    "#{database_config.adapter}://#{database_config.username}" \
      ":#{database_config.password}@#{database_config.host}:" \
      "#{database_config.port}/#{database_config.database}"
  end
end
