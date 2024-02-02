require 'app_helper'

RSpec.describe LoginUser do
  let(:email) { 'test@example.com' }
  let(:password) { 'password123' }

  describe '.call' do
    it 'calls the instance method' do
      allow(LoginUser).to receive(:new).and_call_original
      expect_any_instance_of(LoginUser).to receive(:call)
      LoginUser.call(email: email, password: password)
    end
  end

  describe '#call' do
    context 'when user is found and password is valid' do
      let!(:user) do
        RegisterNewUser.create(
          email: email, password: password, password_verification: password
        )
      end

      it 'returns a successful result' do
        result = LoginUser.new(email: email, password: password).call
        expect(result).to be_success
        expect(result.value).to eq(user)
      end
    end

    context 'when user is not found' do
      it 'returns a failure result with an error message' do
        result = LoginUser.new(email: 'nonexistent@example.com', password: password).call
        expect(result).to be_failure
        expect(result.errors).to include(a_hash_including(field: 'user', error_messages: 'cannot find user'))
      end
    end

    context 'when password is invalid' do
      let(:user) { create(:user, email: email, password: 'original_password') }

      it 'returns a failure result with an error message' do
        result = LoginUser.new(email: email, password: 'wrong_password').call
        expect(result).to be_failure
        expect(result.errors).to include(a_hash_including(field: 'user', error_messages: 'invalid password'))
      end
    end
  end
end
