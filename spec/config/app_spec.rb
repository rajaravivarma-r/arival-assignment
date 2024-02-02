# frozen_string_literal: true

require 'app_helper'

RSpec.describe App do
  let(:adapter) { 'postgres' }
  let(:max_connections) { 5 }

  describe '.set_config' do
    let(:database) { 'arival-test' }
    let(:username) { 'arival' }
    let(:password) { 'arival-password' }
    let(:configurations) do
      {
        'adapter' => adapter,
        'max_connections' => max_connections,
        'database' => database,
        'username' => username,
        'password' => password
      }
    end
    let(:config_name) { :database_config }

    it 'loads the provided configurations into the corresponding config' do
      described_class.set_config(configurations:, config_name:)
      expect(described_class.config.database_config.adapter).to eq(adapter)
      expect(described_class.config.database_config.max_connections).to eq(max_connections)
      expect(described_class.config.database_config.database).to eq(database)
      expect(described_class.config.database_config.username).to eq(username)
      expect(described_class.config.database_config.password).to eq(password)
    end
  end

  describe 'application configurations' do
    around do |example|
      old_environment = described_class.config.environment
      described_class.config.environment = current_environment

      old_database = ENV.fetch('DATABASE_NAME', nil)
      old_username = ENV.fetch('DATABASE_USERNAME', nil)
      old_password = ENV.fetch('DATABASE_PASSWORD', nil)
      old_jwt_sign_private_key = ENV.fetch('JWT_TOKEN_SIGN_PRIVATE_KEY', nil)
      old_jwt_sign_public_key = ENV.fetch('JWT_TOKEN_SIGN_PUBLIC_KEY', nil)

      old_redis_host = ENV.fetch('REDIS_HOST', nil)
      old_redis_port = ENV.fetch('REDIS_PORT', nil)
      old_redis_password = ENV.fetch('REDIS_PASSWORD', nil)

      ENV['DATABASE_NAME'] = database
      ENV['DATABASE_USERNAME'] = username
      ENV['DATABASE_PASSWORD'] = password
      ENV['JWT_TOKEN_SIGN_PRIVATE_KEY'] = jwt_sign_private_key
      ENV['JWT_TOKEN_SIGN_PUBLIC_KEY'] = jwt_sign_public_key

      ENV['REDIS_HOST'] = redis_host
      ENV['REDIS_PORT'] = redis_port
      ENV['REDIS_PASSWORD'] = redis_password

      # Reload for every example to reflect the ENV changes
      load described_class.config.config_path.join('environment.rb')
      example.run

      described_class.config.environment = old_environment
      ENV['DATABASE_NAME'] = old_database
      ENV['DATABASE_USERNAME'] = old_username
      ENV['DATABASE_PASSWORD'] = old_password
      ENV['JWT_TOKEN_SIGN_PRIVATE_KEY'] = old_jwt_sign_private_key
      ENV['JWT_TOKEN_SIGN_PUBLIC_KEY'] = old_jwt_sign_public_key

      ENV['REDIS_HOST'] = old_redis_host
      ENV['REDIS_PORT'] = old_redis_port
      ENV['REDIS_PASSWORD'] = old_redis_password
    end

    let(:current_environment) { 'development' }
    let(:database) { 'arival-development' }
    let(:username) { 'arival' }
    let(:password) { '49e02e8faf' }
    let(:jwt_sign_private_key) do
      %(-----BEGIN RSA PRIVATE KEY-----
MIIBOwIBAAJBANxjO/jH8pHEFjguHy+h43yzR+wl9fW3fCO3lq4hJqqc389Cwjwp
wIc64RGaNzCe2c7B5NaNjKYosXlYt25q2N8CAwEAAQJAbo/iEEbO7E3BD+IjhxPi
Ojb+x/urTuAECS8bCrRa34/w50WEoQUMVNuR9/eRhAkzuGQlby1ww6cb3FJC9e6R
kQIhAP3EPlmsu9x0EA/F7u92soG7kvwXw6cUC/kIMZbVv2r7AiEA3lPJB8mEnde2
G/BymXh3KUQ5CGTxW8ZYFmWM2pxtJG0CIFWhujSCgGY02BKqhSVTVYtHo6Lj1gb0
UdH4PNucR1qvAiEAqaIb/MkRWq2/0UmA5wA3S1E2guUiEvgfNdd9xT8dN3ECIQD4
lyBwHHUQF+bA6fezpZ8sR0BCsWq+tvou1HkoqCqxxg==
-----END RSA PRIVATE KEY-----)
    end
    let(:jwt_sign_public_key) do
      %(-----BEGIN PUBLIC KEY-----
MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANxjO/jH8pHEFjguHy+h43yzR+wl9fW3
fCO3lq4hJqqc389CwjwpwIc64RGaNzCe2c7B5NaNjKYosXlYt25q2N8CAwEAAQ==
-----END PUBLIC KEY-----)
    end
    let(:redis_password) { 'redisPass' }
    let(:redis_host) { 'redis' }
    let(:redis_port) { '6379' }

    it 'loads the application configuration' do
      expect(described_class.config.database_config.adapter).to eq(adapter)
      expect(described_class.config.database_config.max_connections).to eq(max_connections)
      expect(described_class.config.database_config.database).to eq(database)
      expect(described_class.config.database_config.username).to eq(username)
      expect(described_class.config.database_config.password).to eq(password)

      expect(described_class.config.secret.jwt_sign_private_key).to be_a(OpenSSL::PKey::RSA)
      expect(described_class.config.secret.jwt_sign_public_key).to be_a(OpenSSL::PKey::RSA)
      expect(described_class.config.secret.jwt_sign_private_key.to_s.strip).to eq(jwt_sign_private_key)
      expect(described_class.config.secret.jwt_sign_public_key.to_s.strip).to eq(jwt_sign_public_key)
      expect(described_class.config.secret.jwt_sign_algorithm).not_to be_empty

      expect(described_class.config.redis.password).to eq(redis_password)
      expect(described_class.config.redis.host).to eq(redis_host)
      expect(described_class.config.redis.port.to_s).to eq(redis_port)
    end
  end
end
