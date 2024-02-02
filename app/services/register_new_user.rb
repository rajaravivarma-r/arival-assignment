# frozen_string_literal: true

# Use this class to create valid users in the system
# All the validations are handled here
class RegisterNewUser < BaseService
  attr_reader :email, :password, :password_verification

  class << self
    def call(email:, password:, password_verification:)
      new(email:, password:, password_verification:).call
    end
  end

  def initialize(email:, password:, password_verification:)
    super()
    @email = email
    @password = password
    @password_verification = password_verification
  end

  def call
    if (validation_result = validate_params!).failure?
      return Result.failure(errors: errors_from_hash(validation_result.errors.to_h))
    end

    password_hash = BCrypt::Password.create(password)

    require 'byebug'; byebug
    user = User.create(
      email:,
      password_hash:
    )
    Result.success(value: user)
  rescue Sequel::UniqueConstraintViolation => e
    Result.failure(
      errors: construct_error(field: 'user', error_messages: 'User already exists')
    )
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
