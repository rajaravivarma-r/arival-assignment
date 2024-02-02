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
      ENV['DATABASE_NAME'] = database
      ENV['DATABASE_USERNAME'] = username
      ENV['DATABASE_PASSWORD'] = password
      ENV['JWT_TOKEN_SIGN_PRIVATE_KEY'] = jwt_sign_private_key
      ENV['JWT_TOKEN_SIGN_PUBLIC_KEY'] = jwt_sign_public_key

      # Reload for every example to reflect the ENV changes
      load described_class.config.config_path.join('environment.rb')
      example.run

      described_class.config.environment = old_environment
      ENV['DATABASE_NAME'] = old_database
      ENV['DATABASE_USERNAME'] = old_username
      ENV['DATABASE_PASSWORD'] = old_password
      ENV['JWT_TOKEN_SIGN_PRIVATE_KEY'] = old_jwt_sign_private_key
      ENV['JWT_TOKEN_SIGN_PUBLIC_KEY'] = old_jwt_sign_public_key
    end

    let(:current_environment) { 'development' }
    let(:database) { 'arival-development' }
    let(:username) { 'arival' }
    let(:password) { '49e02e8faf' }
    let(:jwt_sign_private_key) { 'private_key' }
    let(:jwt_sign_public_key) { 'public_key' }

    it 'loads the application configuration' do
      expect(described_class.config.database_config.adapter).to eq(adapter)
      expect(described_class.config.database_config.max_connections).to eq(max_connections)
      expect(described_class.config.database_config.database).to eq(database)
      expect(described_class.config.database_config.username).to eq(username)
      expect(described_class.config.database_config.password).to eq(password)

      expect(described_class.config.secret.jwt_sign_private_key).to eq(jwt_sign_private_key)
      expect(described_class.config.secret.jwt_sign_public_key).to eq(jwt_sign_public_key)
      expect(described_class.config.secret.jwt_sign_algorithm).not_to be_empty
    end
  end
end
