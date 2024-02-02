# frozen_string_literal: true

# Handle redis connection
class RedisConnection
  attr_reader :host, :port, :password

  def initialize(
    host: App.config.redis.host,
    port: App.config.redis.port,
    password: App.config.redis.password
  )
    @host = host
    @port = port
    @password = password
  end

  def url(database: 0)
    "redis://#{password}@#{host}:#{port}/#{database}"
  end
end
