# frozen_string_literal: true

module Api
  module V1
    # This will determine the correct login strategy for an user
    # based on email password with or without OTP
    class LoginStrategy
      attr_reader :email, :password, :otp

      class << self
        def execute(...)
          new(...).execute
        end
      end

      def initialize(email:, password:, otp: nil)
        @email = email
        @password = password
        @otp = otp
      end

      def execute
        login_result = LoginUser.call(email:, password:)
        return login_result if login_result.failure?

        user = login_result.value
        return login_result unless user.two_factor_authentication_enabled?

        LoginUserWithOtp.call(verified_user: user, otp:)
      end
    end
  end
end
