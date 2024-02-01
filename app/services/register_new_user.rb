# frozen_string_literal: true

class RegisterNewUser < BaseService
  attr_reader :email, :password, :password_verification

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
    if (validation_result = validate_params!).failure?
      return Result.new(success: false, errors: validation_result.errors)
    end
    password_hash = BCrypt::Password.create(password)

    user = User.create(
      email: email,
      password_hash: password_hash
    )
    Result.new(success: true, value: user)
  rescue Sequel::Error, PG::Error => e
    Result.new(success: false, errors: [e.message])
  end

  private

  def validate_params!
    new_user_contract = Validators::RequestData::NewUserContract.new
    new_user_contract.call(json_request_body)
  end
end
