# frozen_string_literal: true

require 'app_helper'

class AuthorizedController < Sinatra::Base
  use JWTAuthorization

  before do
    content_type :json
  end

  get '/test' do
    status 200
    { success: true }.to_json
  end

  post '/test' do
    status 200
    { success: true }.to_json
  end

  post '/site/path' do
    status 200
    { success: true }.to_json
  end
end

RSpec.describe JWTAuthorization do
  def app
    AuthorizedController
  end

  def authorization_header(token)
    { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
  end

  let(:email) { 'test@example.com' }
  let(:password) { 'password' }
  let(:user) { User.create(email:, password:) }
  let(:valid_token) do
    UserSessionToken.issue(user, expires_in_seconds: 60)
  end
  let(:expired_token) do
    UserSessionToken.issue(user, expires_in_seconds: -60)
  end

  context 'when a valid token is provided' do
    it 'calls the app with the user set in the env' do
      %i[get post].each do |method|
        send(method, '/test', {}, authorization_header(valid_token))

        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)
        expect(response['success']).to be(true)
      end
    end
  end

  context 'when the token has expired' do
    it 'returns a 403 Forbidden response' do
      %i[get post].each do |method|
        send(method, '/test', {}, authorization_header(expired_token))

        response = last_response_json
        expect(last_response.status).to eq(403)
        expect(response['errors']).to include({ 'token' => ['The token has expired.'] })
      end
    end
  end

  context 'when no token is provided' do
    it 'returns a 401 Unauthorized response' do
      %i[get post].each do |method|
        send(method, '/test', {}, {})

        response = last_response_json
        expect(last_response.status).to eq(401)
        expect(response['errors']).to include({ 'token' => ['A token must be passed.'] })
      end
    end

    context 'when visiting site url' do
      it 'returns a 200 Unauthorized response' do
        post '/site/path', {}, {}

        response = last_response_json
        expect(last_response.status).to eq(200)
        expect(response['success']).to be(true)
      end
    end
  end
end
