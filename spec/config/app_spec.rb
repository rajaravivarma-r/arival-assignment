# frozen_string_literal: true

require 'app_helper'

RSpec.describe App do
  describe '.set_config' do
    let(:adapter) { 'postgres' }
    let(:pool) { 5 }
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
end
