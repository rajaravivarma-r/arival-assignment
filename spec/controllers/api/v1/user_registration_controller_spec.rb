# frozen_string_literal: true

require 'app_helper'

RSpec.describe Api::V1::UserRegistrationController do
  def app
    described_class
  end

  let(:valid_params) do
    {
      email: 'test@example.com',
      password: 'password123',
      password_verification: 'password123'
    }
  end

  let(:invalid_params) do
    {
      email: 'invalid-email',
      password: 'password123',
      password_verification: 'password234'
    }
  end

  describe 'POST /users' do
    context 'when user creation is successful' do
      it 'returns a success response' do
        post '/api/v1/users', valid_params.to_json, { 'CONTENT_TYPE' => 'application/json' }

        body = JSON.parse(last_response.body)
        expect(last_response.status).to eq(201)
        expect(body).to eq({ 'data' => { 'email' => 'test@example.com' } })
      end
    end

    context 'when user creation fails' do
      it 'returns an error response' do
        expected_errors = [
          { 'email' => ['has invalid format'] },
          { 'password' => ['should match password_verification'] }
        ]
        post '/api/v1/users', invalid_params.to_json, { 'CONTENT_TYPE' => 'application/json' }

        body = JSON.parse(last_response.body)
        expect(last_response.status).to eq(400)
        expect(body['errors']).to eq(expected_errors)
      end
    end
  end
end
