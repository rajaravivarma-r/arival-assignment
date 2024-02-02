# frozen_string_literal: true

# Class to issue session token to an user
class UserSessionToken
  DEFAULT_EXPIRES_IN = 4 * 3600 # 4 hours

  class << self
    def issue(user, expires_in_seconds: DEFAULT_EXPIRES_IN)
      expires_at = Time.now.to_i + expires_in_seconds
      payload = { email: user.email, exp: expires_at }
      SessionToken.new.encode_to_string(payload:)
    end
  end
end
