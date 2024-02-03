# frozen_string_literal: true

# Service to handle user login
class LoginUserWithOtp < BaseService
  attr_reader :verified_user, :otp

  class << self
    def call(...)
      new(...).call
    end
  end

  # Don't send user who does not have two_factor_authentication_enabled
  # Only send user who has already passed a valid password
  # Use LoginStrategy to handle login
  def initialize(verified_user:, otp:)
    super()
    @verified_user = verified_user
    @otp = otp
  end

  def call
    second_factor = verified_user.second_factor
    if second_factor.valid_user_otp?(otp)
      Result.success(value: verified_user)
    else
      error = construct_error(field: 'otp', error_messages: 'invalid otp')
      Result.failure(errors: error)
    end
  end
end
