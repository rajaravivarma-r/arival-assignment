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
  let!(:user) { User.create(email:, password:) }

  describe 'POST /login' do
    context 'when valid email and password are provided' do
      it 'returns a success response with a token' do
        post '/api/v1/login', valid_user_params.to_json, { 'CONTENT_TYPE' => 'application/json' }

        expect(last_response.status).to eq(200)

        response_body = JSON.parse(last_response.body)
        expect(response_body.dig('data', 'token').to_s.strip).not_to be_empty
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

    context 'when two factor authentication is enabled' do
      let(:second_factor) { SecondFactor.enable_for_user(user) }
      let(:totp) do
        ROTP::TOTP.new(second_factor.otp_secret, issuer: SecondFactor::USER_TOTP_ISSUER)
      end
      let(:otp) { totp.now }
      let(:valid_params) { { email:, password:, otp: } }

      context 'when a valid otp is passed' do
        it 'returns a success response' do
          json_post '/api/v1/login', valid_params

          expect(last_response.status).to eq(200)

          response_body = last_response_json
          expect(response_body.dig('data', 'token').strip).not_to be_empty
        end
      end

      context 'when an invalid otp is passed' do
        it 'returns a failure response' do
          json_post '/api/v1/login', valid_params.merge(otp: '12345678')

          expect(last_response.status).to eq(401)

          response_body = last_response_json
          expect(response_body['errors']).to(
            include({ 'otp' => ['invalid otp'] })
          )
        end
      end

      context 'when a valid backup code is passed' do
        let(:backup_code) { second_factor.backup_codes.first }

        it 'returns a success response' do
          json_post '/api/v1/login', valid_params.merge(otp: backup_code.code)

          expect(last_response.status).to eq(200)

          response_body = last_response_json
          expect(response_body.dig('data', 'token').strip).not_to be_empty
        end
      end

      context 'when a utilized backup code is passed' do
        let(:backup_code) { second_factor.backup_codes.first }

        it 'returns a failure response' do
          backup_code.utilize!
          json_post '/api/v1/login', valid_params.merge(otp: backup_code.code)

          expect(last_response.status).to eq(401)

          response_body = last_response_json
          expect(response_body['errors']).to(
            include({ 'otp' => ['invalid otp'] })
          )
        end
      end
    end
  end
end
