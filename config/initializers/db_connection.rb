# frozen_string_literal: true

database_config = App.config.database_config
database_url = "#{database_config.adapter}://#{database_config.username}:#{database_config.password}@#{database_config.host}:#{database_config.port}/#{database_config.database}"

DB = Sequel.connect(
  database_url,
  max_connections: database_config.max_connections,
  logger: Logger.new('log/db.log')
)
