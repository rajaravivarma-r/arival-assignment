# frozen_string_literal: true

# User model
class User < Sequel::Model
  plugin :timestamps, update_on_create: true

  one_to_one :second_factor

  def valid_password?(password)
    BCrypt::Password.new(password_hash) == password
  end

  def two_factor_authentication_enabled?
    return false if second_factor.nil?

    second_factor.enabled?
  end

  def password=(new_password)
    return if new_password.nil? || new_password.empty?

    self.password_hash = BCrypt::Password.create(new_password)
  end
end
