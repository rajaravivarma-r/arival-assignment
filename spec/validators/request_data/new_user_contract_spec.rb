require 'spec_helper'
require_relative '../../../app/validators/request_data/new_user_contract'

RSpec.describe Validators::RequestData::NewUserContract do
  let(:contract) { described_class.new }

  describe 'with valid parameters' do
    let(:valid_params) do
      {
        email: 'user@example.com',
        password: 'password123',
        password_verification: 'password123'
      }
    end

    it 'is valid' do
      result = contract.call(valid_params)
      expect(result).to be_success
    end
  end

  describe 'with invalid email format' do
    let(:invalid_email_params) do
      {
        email: 'invalid_email',
        password: 'password123',
        password_verification: 'password123'
      }
    end

    it 'fails validation' do
      result = contract.call(invalid_email_params)
      expect(result).to be_failure
      expect(result.errors.to_h).to include(email: ['has invalid format'])
    end
  end

  describe 'with non-matching passwords' do
    let(:non_matching_password_params) do
      {
        email: 'user@example.com',
        password: 'password123',
        password_verification: 'different_password'
      }
    end

    it 'fails validation' do
      result = contract.call(non_matching_password_params)
      expect(result).to be_failure
      expect(result.errors.to_h).to include(password: ['should match password_verification'])
    end
  end
end
