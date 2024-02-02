# frozen_string_literal: true

RSpec.shared_context 'with logged in user' do
  def authorization_header(token)
    { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
  end

  def app
    described_class
  end

  let(:email) { 'test@example.com' }
  let(:password) { 'password' }
  let(:current_user) do
    RegisterNewUser.call(
      email:, password:, password_verification: password
    ).value
  end
  let(:valid_token) do
    UserSessionToken.issue(current_user, expires_in_seconds: 60)
  end
  let(:expired_token) do
    UserSessionToken.issue(current_user, expires_in_seconds: -60)
  end
end
