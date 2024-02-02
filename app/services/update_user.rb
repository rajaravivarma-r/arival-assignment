# frozen_string_literal: true

# Service to handle user updates
class UpdateUser < BaseService
  attr_reader :user, :updated_attributes

  def initialize(user:, updated_attributes:)
    @user = user
    @updated_attributes = updated_attributes.transform_keys(&:to_sym)
  end

  def call
    # NOTE: Don't allow email to be updated
    updated_attributes.delete(:email)
    user.update(updated_attributes)
    Result.success(value: user)
  rescue Sequel::Error, PG::Error
    Result.failure(
      errors: construct_error(field: 'user', error_messages: 'Could not update user')
    )
  end
end
