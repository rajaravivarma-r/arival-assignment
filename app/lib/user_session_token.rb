# frozen_string_literal: true

# Class to issue session token to an user
class UserSessionToken
  class << self
    def issue(user)
      payload = { email: user.email }
      SessionToken.new.encode_to_string(payload:)
    end
  end
end
