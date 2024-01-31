# frozen_string_literal: true

require 'app_helper'

RSpec.describe Password do
  let(:plain_text_password) { 'SecurePassword' }
  let(:password) { described_class.new(plain_text_password:) }

  around do |example|
    # Running with a small cost (2) compared to the default cost which makes
    # the tests slow
    described_class.with_cost(2) do
      example.run
    end
  end

  describe '.from_hash' do
    let(:stored_password) { Password.create(plain_text_password:) }
    let(:password) { described_class.from_hash(stored_password.hash) }

    it 'creates another Password instance from the hash' do
      expect(stored_password == password).to be(true)
    end
  end

  describe '#hash' do
    it 'returns the hashed format of the password' do
      expect(password).to eq(plain_text_password)
    end
  end

  describe '#==' do
    it 'compares with the plain text password' do
      expect(password == plain_text_password).to be(true)
      expect(password == 'wrongPassword').to be(false)
    end

    it 'compares with another password object' do
      password_object = Password.create(plain_text_password:)
      wrong_password_object = Password.create(
        plain_text_password: 'wrongPassword'
      )
      expect(password == password_object).to be(true)
      expect(password == wrong_password_object).to be(true)
    end
  end
end
