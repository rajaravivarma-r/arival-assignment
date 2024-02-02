# frozen_string_literal: true

require 'app_helper'

RSpec.describe UserSessionToken do
  let(:email) { 'test@example.com' }
  let!(:user) do
    RegisterNewUser.call(
      email:,
      password: 'samplePass',
      password_verification: 'samplePass'
    ).value
  end

  describe '.issue' do
    it 'issues a session token for the user' do
      token = described_class.issue(user)
      expect(token).not_to be_empty
      session_token = SessionToken.new
      expect(session_token.decode_payload(token_string: token).first).to(
        include({ 'email' => email, 'exp' => anything })
      )
    end
  end

  describe '.get_user' do
    it 'fetches the user of the token' do
      token = described_class.issue(user)
      fetched_user = described_class.get_user(token)
      expect(user.email).to eq(fetched_user.email)
    end
  end
end
