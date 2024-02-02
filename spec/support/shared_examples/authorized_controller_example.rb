# frozen_string_literal: true

RSpec.shared_examples 'an authorized controller' do
  def authorization_header(token)
    { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
  end

  def app
    described_class
  end

  let(:email) { 'test@example.com' }
  let(:password) { 'password' }
  let(:user) do
    RegisterNewUser.call(
      email:, password:, password_verification: password
    ).value
  end
  let(:valid_token) do
    UserSessionToken.issue(user, expires_in_seconds: 60)
  end
  let(:expired_token) do
    UserSessionToken.issue(user, expires_in_seconds: -60)
  end

  let(:paths) do
    {
      get: '/sample_authorized_get_route'
    }
  end

  before do
    paths.each do |method, route|
      described_class.send(method, route) do
        status(200)
        { success: true }.to_json
      end
    end
  end

  context 'when a valid token is provided' do
    it 'calls the app with the user set in the env' do
      paths.each do |method, route|
        send(method, route, {}, authorization_header(valid_token))

        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)
        expect(response['success']).to be(true)
      end
    end
  end

  context 'when the token has expired' do
    it 'returns a 403 Forbidden response' do
      paths.each do |method, route|
        send(method, route, {}, authorization_header(expired_token))

        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(403)
        expect(response['errors']).to include({ 'token' => ['The token has expired.'] })
      end
    end
  end

  context 'when no token is provided' do
    it 'returns a 401 Unauthorized response' do
      paths.each do |method, route|
        send(method, route, {}, {})

        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(401)
        expect(response['errors']).to include({ 'token' => ['A token must be passed.'] })
      end
    end
  end
end
