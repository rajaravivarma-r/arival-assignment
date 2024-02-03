# frozen_string_literal: true

require 'app_helper'

RSpec.describe Api::V1::SecondFactorsController do
  def app
    Api::V1::SecondFactorsController
  end

  include_context 'with logged in user'

  describe 'POST /two_factors/enable' do
    context 'when enabling for the first time' do
      it 'enables two factors for the user and returns a serialized response' do
        post '/api/v1/two_factors/enable', {}, authorization_header(valid_token)
        expect(last_response.status).to eq(201)
        created_second_factor = current_user.second_factor
        backup_codes = created_second_factor.backup_codes.map(&:code).sort
        expected_data = {
          'id' => created_second_factor.id,
          'otp_secret' => created_second_factor.otp_secret,
          'enabled' => true,
          'created_at' => anything,
          'updated_at' => anything
        }
        data = last_response_json['data']
        expect(data).to include(expected_data)
        expect(data['backup_codes'].sort).to eq(backup_codes)
        expect(data['qr_code']).not_to be_empty
        expect(data.dig('qr_code', 'base64')).not_to be_empty
        expect(data.dig('qr_code', 'url')).not_to be_empty
      end
    end

    context 'when enable is called for the second time' do
      before do
        post '/api/v1/two_factors/enable', {}, authorization_header(valid_token)
      end

      it 'enables two factors for the user and returns a serialized response' do
        post '/api/v1/two_factors/enable', {}, authorization_header(valid_token)

        expect(last_response.status).to eq(200)
        created_second_factor = current_user.second_factor
        backup_codes = created_second_factor.backup_codes.map(&:code).sort
        expected_data = {
          'id' => created_second_factor.id,
          'otp_secret' => created_second_factor.otp_secret,
          'enabled' => true,
          'created_at' => anything,
          'updated_at' => anything
        }
        data = last_response_json['data']
        expect(data).to include(expected_data)
        expect(data['backup_codes'].sort).to eq(backup_codes)
      end
    end
  end

  describe 'PUT /two_factors/disable' do
    context 'when an second factor was enabled' do
      before do
        post '/api/v1/two_factors/enable', {}, authorization_header(valid_token)
      end

      it 'disables and responds with the second_factor json' do
        put '/api/v1/two_factors/disable', {}, authorization_header(valid_token)

        expect(last_response.status).to eq(200)
        created_second_factor = current_user.second_factor
        expected_data = {
          'id' => created_second_factor.id,
          'otp_secret' => created_second_factor.otp_secret,
          'created_at' => anything,
          'enabled' => false,
          'updated_at' => anything
        }
        data = last_response_json['data']
        expect(data).to include(expected_data)
        expect(data.dig('qr_code', 'base64')).to be_nil
        expect(data.dig('qr_code', 'url')).to be_nil
      end
    end

    context 'when an second factor was not enabled already' do
      it 'disables and responds with the second_factor json' do
        put '/api/v1/two_factors/disable', {}, authorization_header(valid_token)

        expect(last_response.status).to eq(404)
        expected_data = { 'second_factor' => ['two factor authentication is not enabled'] }
        expect(last_response_json['errors']).to include(expected_data)
      end
    end
  end
end
