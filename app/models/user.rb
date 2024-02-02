# frozen_string_literal: true

# User model
class User < Sequel::Model
  plugin :timestamps, update_on_create: true

  # Instance method to verify a password
  def valid_password?(password)
    BCrypt::Password.new(password_hash) == password
  end
end
