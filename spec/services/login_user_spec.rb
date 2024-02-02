# frozen_string_literal: true

require 'app_helper'

RSpec.describe LoginUser do
  let(:email) { 'test@example.com' }
  let(:password) { 'password123' }

  describe '.call' do
    let(:service) { instance_double(described_class, call: true) }

    it 'calls the instance method' do
      allow(described_class).to receive(:new).and_return(service)
      described_class.call(email:, password:)
      expect(service).to have_received(:call)
    end
  end

  describe '#call' do
    context 'when user is found and password is valid' do
      let!(:user) do
        RegisterNewUser.call(
          email:, password:, password_verification: password
        ).value
      end

      it 'returns a successful result' do
        result = described_class.new(email:, password:).call
        expect(result).to be_success
        expect(result.value).to eq(user)
      end
    end

    context 'when user is not found' do
      it 'returns a failure result with an error message' do
        result = described_class.new(email: 'nonexistent@example.com', password:).call
        expect(result).not_to be_success
        expect(result.errors.to_h).to include({ 'user' => ['cannot find user'] })
      end
    end

    context 'when password is invalid' do
      before do
        RegisterNewUser.call(
          email:, password:, password_verification: password
        ).value
      end

      it 'returns a failure result with an error message' do
        result = described_class.new(email:, password: 'wrong_password').call
        expect(result).not_to be_success
        expect(result.errors.to_h).to include({ 'user' => ['invalid password'] })
      end
    end
  end
end
