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
      return Result.failure(errors: errors_from_hash(validation_result.errors.to_h))
    end
    password_hash = BCrypt::Password.create(password)

    user = User.create(
      email: email,
      password_hash: password_hash
    )
    Result.success(value: user)
  rescue Sequel::Error, PG::Error => e
    Result.failure(
      errors: construct_error(field: 'user', error_messages: 'Could not create user')
    )
  end

  private

  def validate_params!
    new_user_contract = Validators::RequestData::NewUserContract.new
    new_user_contract.call(email:, password:, password_verification:)
  end
end
