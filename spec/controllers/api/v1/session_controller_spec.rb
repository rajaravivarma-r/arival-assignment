# frozen_string_literal: true

require 'app_helper'

RSpec.describe Api::V1::SessionController do
  def app
    described_class
  end

  let(:email) {  'user@example.com' }
  let(:password) { 'password123' }
  let(:valid_user_params) { { email:, password: } }
  let(:invalid_password_params) do
    {
      email:,
      password: 'invalid_password'
    }
  end

  before do
    RegisterNewUser.call(
      email:,
      password:,
      password_verification: password
    ).value
  end

  describe 'POST /login' do
    context 'when valid email and password are provided' do
      it 'returns a success response with a token' do
        post '/api/v1/login', valid_user_params.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(200)

        response_body = JSON.parse(last_response.body)
        expect(response_body.dig('data', 'token')).not_to be_nil
      end
    end

    context 'when the email is valid but password is invalid' do
      it 'returns a failure response with errors' do
        post '/api/v1/login', invalid_password_params.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(401)

        response_body = JSON.parse(last_response.body)
        expect(response_body['errors']).to(
          include({ 'user' => ['invalid password'] })
        )
      end
    end
  end
end
