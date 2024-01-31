# frozen_string_literal: true

require 'app_helper'

RSpec.describe App do
  let(:adapter) { 'postgres' }
  let(:pool) { 5 }

  describe '.set_config' do
    let(:database) { 'arival-test' }
    let(:username) { 'arival' }
    let(:password) { 'arival-password' }
    let(:configurations) do
      {
        'adapter' => adapter,
        'pool' => pool,
        'database' => database,
        'username' => username,
        'password' => password
      }
    end
    let(:config_name) { :database_config }

    it 'loads the provided configurations into the corresponding config' do
      described_class.set_config(configurations:, config_name:)
      expect(described_class.config.database_config.adapter).to eq(adapter)
      expect(described_class.config.database_config.pool).to eq(pool)
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
      ENV['DATABASE_NAME'] = database
      ENV['DATABASE_USERNAME'] = username
      ENV['DATABASE_PASSWORD'] = password

      # Reload for every example to reflect the ENV changes
      load described_class.config.config_path.join('environment.rb')
      example.run

      described_class.config.environment = old_environment
      ENV['DATABASE_NAME'] = old_database
      ENV['DATABASE_USERNAME'] = old_username
      ENV['DATABASE_PASSWORD'] = old_password
    end

    context 'when in development environment' do
      let(:current_environment) { 'development' }
      let(:database) { 'arival-development' }
      let(:username) { 'arival' }
      let(:password) { '49e02e8faf' }

      it 'loads the application configuration' do
        expect(described_class.config.database_config.adapter).to eq(adapter)
        expect(described_class.config.database_config.pool).to eq(pool)
        expect(described_class.config.database_config.database).to eq(database)
        expect(described_class.config.database_config.username).to eq(username)
        expect(described_class.config.database_config.password).to eq(password)
      end
    end

    context 'when in test environment' do
      let(:current_environment) { 'test' }
      let(:database) { 'arival-test' }
      let(:username) { 'arival' }
      let(:password) { '59dd1329ce' }

      it 'loads the application configuration' do
        expect(described_class.config.database_config.adapter).to eq(adapter)
        expect(described_class.config.database_config.pool).to eq(pool)
        expect(described_class.config.database_config.database).to eq(database)
        expect(described_class.config.database_config.username).to eq(username)
        expect(described_class.config.database_config.password).to eq(password)
      end
    end

    context 'when in production environment' do
      let(:current_environment) { 'production' }
      let(:database) { 'arival-production' }
      let(:username) { 'arival' }
      let(:password) { '8eb9c1526e' }

      it 'loads the application configuration' do
        expect(described_class.config.database_config.adapter).to eq(adapter)
        expect(described_class.config.database_config.pool).to eq(pool)
        expect(described_class.config.database_config.database).to eq(database)
        expect(described_class.config.database_config.username).to eq(username)
        expect(described_class.config.database_config.password).to eq(password)
      end
    end
  end
end
