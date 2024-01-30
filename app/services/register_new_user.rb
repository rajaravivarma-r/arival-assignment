# frozen_string_literal: true

class RegisterNewUser
  class << self
    def call(email:, password:, password_verification:)
      new(email:, password:, password_verification:).call
    end
  end

  def initialize(email:, password:, password_verification:)
    @email = email
    @password = password
    @password_verification = password_verification
  end

  def call
    user = User.new(email: email, password: password, password_verification: password_verification)
    user_repository = UserRepository.new
    user_repository.create(user)
  end
end
