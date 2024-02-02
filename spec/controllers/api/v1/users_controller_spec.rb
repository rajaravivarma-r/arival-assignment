# frozen_string_literal: true

require 'app_helper'

RSpec.describe Api::V1::UsersController do
  def app
    described_class
  end

  it_behaves_like 'an authorized controller'
  include_context 'logged in user'

  describe 'PUT /update' do
    context 'when valid params are passed' do
      let(:new_password) { 'newPassword' }
      it 'updates the user object' do
        json_put '/api/v1/update', { user: { password: new_password } }, authorization_header(valid_token)
        response = last_response_json
        expect(last_response.status).to eq(200)
        updated_current_user = User.find(id: current_user.id)
        expect(updated_current_user.valid_password?(new_password)).to be(true)
      end
    end

    context 'when an error occurs' do
      it 'updates the user object' do
        json_put '/api/v1/update', { user: { unknown_attribute: 'value' } }, authorization_header(valid_token)
        response = last_response_json
        expect(last_response.status).to eq(400)
        expect(response['errors']).to eq([{'user' => ['Could not update user']}])
      end
    end
  end
end
