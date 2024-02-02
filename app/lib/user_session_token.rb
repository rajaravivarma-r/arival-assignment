# frozen_string_literal: true

# Class to issue session token to an user
class UserSessionToken
  DEFAULT_EXPIRES_IN = 4 * 3600 # 4 hours

  class << self
    def issue(user, expires_in_seconds: DEFAULT_EXPIRES_IN)
      expires_at = Time.now.to_i + expires_in_seconds
      payload = { email: user.email, exp: expires_at }
      session_token.encode_to_string(payload:)
    end

    def get_user(token_string)
      payload = session_token.decode_payload(token_string:).first
      email = payload['email']
      User.find(email:)
    end

    private

    def session_token
      SessionToken.new
    end
  end
end
