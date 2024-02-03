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

  def with_new_values(env_vars)
    old_env_vars = {}
    env_vars.each do |var_name, var_value|
      old_env_vars[var_name] = ENV.fetch(var_name, nil)
      ENV[var_name] = var_value
    end
    yield
  ensure
    old_env_vars.each do |var_name, old_val|
      ENV[var_name] = old_val
    end
  end

  describe 'application configurations' do
    around do |example|
      old_environment = described_class.config.environment
      described_class.config.environment = current_environment
      new_env_vars = {
        'DATABASE_NAME' => database,
        'DATABASE_USERNAME' => username,
        'DATABASE_PASSWORD' => password,
        'JWT_TOKEN_SIGN_PRIVATE_KEY' => jwt_sign_private_key,
        'JWT_TOKEN_SIGN_PUBLIC_KEY' => jwt_sign_public_key,
        'REDIS_HOST' => redis_host,
        'REDIS_PORT' => redis_port,
        'REDIS_PASSWORD' => redis_password,
        'EMAIL_SENDER' => email_sender,
        'MAILJET_API_KEY' => mailjet_api_key,
        'MAILJET_SECRET_KEY' => mailjet_secret_key,
        'DATA_ENCRYPTION_KEY' => data_encryption_key
      }
      with_new_values(new_env_vars) do
        # Reload for every example to reflect the ENV changes
        load described_class.config.config_path.join('environment.rb')
        example.run
      end
    ensure
      described_class.config.environment = old_environment
      load described_class.config.config_path.join('environment.rb')
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
    let(:email_sender) { 'admin@arival.com' }
    let(:mailjet_api_key) { 'mailJetApiKey' }
    let(:mailjet_secret_key) { 'mailJetSecretKey' }
    let(:data_encryption_key) { '24688fcfa3c7615302546209948d3ba6f763704b9a47a56f6c4479b603779623' }

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
      expect(described_class.config.secret.data_encryption_key).to eq(data_encryption_key)

      expect(described_class.config.redis.password).to eq(redis_password)
      expect(described_class.config.redis.host).to eq(redis_host)
      expect(described_class.config.redis.port.to_s).to eq(redis_port)

      expect(described_class.config.mailer.from).to eq(email_sender)
      expect(described_class.config.mailjet.api_key).to eq(mailjet_api_key)
      expect(described_class.config.mailjet.secret_key).to eq(mailjet_secret_key)
    end
  end
end
