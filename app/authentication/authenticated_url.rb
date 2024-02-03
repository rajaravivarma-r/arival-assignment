# frozen_string_literal: true

# Used to generate expirable URL to be handed over to users
class AuthenticatedUrl
  attr_reader :url, :content, :expires_in_seconds

  class << self
    def generate(...)
      new(...).generate
    end

    def get_content(id)
      redis_client.call('GET', id)
    end

    def redis_client
      RedisConnection.new.client
    end
  end

  # Expects url to have the format '/path/%{code}
  # The code will be replaced with an unique string
  def initialize(url:, content:, expires_in_seconds: 3600)
    @url = url
    @content = content
    @expires_in_seconds = expires_in_seconds
  end

  def generate
    id = SecureRandom.uuid.gsub('-', '')
    unique_url = format(url, code: id)
    redis_client.call('SET', id, content.to_s)
    unique_url
  end

  private

  def redis_client
    self.class.redis_client
  end
end
