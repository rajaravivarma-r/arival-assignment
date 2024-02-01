require 'app_helper'

# spec/register_new_user_spec.rb
require 'spec_helper'
require_relative '../register_new_user'

RSpec.describe RegisterNewUser do
  let(:valid_email) { 'user@example.com' }
  let(:valid_password) { 'password123' }
  let(:valid_password_verification) { 'password123' }

  let(:invalid_email) { 'invalid_email' }
  let(:short_password) { 'short' }
  let(:mismatched_password_verification) { 'mismatched_password' }

  describe '.call' do
    context 'with valid parameters' do
      it 'creates a new user' do
        result = described_class.call(
          email: valid_email,
          password: valid_password,
          password_verification: valid_password_verification
        )
        expect(result).to be_a(Result)
        expect(result.success).to be true
        expect(result.value).to be_a(User)
        expect(result.errors).to be_empty
      end
    end

    context 'with invalid parameters' do
      it 'returns an error result' do
        result = described_class.call(
          email: invalid_email,
          password: short_password,
          password_verification: mismatched_password_verification
        )
        expect(result).to be_a(Result)
        expect(result.success).to be false
        expect(result.value).to be_nil
        expect(result.errors).not_to be_empty
      end
    end
  end

  describe '#call' do
    context 'with valid parameters' do
      it 'creates a new user' do
        register_new_user = described_class.new(
          email: valid_email,
          password: valid_password,
          password_verification: valid_password_verification
        )
        result = register_new_user.call
        expect(result).to be_a(Result)
        expect(result.success).to be true
        expect(result.value).to be_a(User)
        expect(result.errors).to be_empty
      end
    end

    context 'with invalid parameters' do
      it 'returns an error result' do
        register_new_user = described_class.new(
          email: invalid_email,
          password: short_password,
          password_verification: mismatched_password_verification
        )
        result = register_new_user.call
        expect(result).to be_a(Result)
        expect(result.success).to be false
        expect(result.value).to be_nil
        expect(result.errors).not_to be_empty
      end
    end
  end
end
