# frozen_string_literal: true

require 'bcrypt'

# A class that abstracts the BCrypt implementation
class Password
  attr_reader :plain_text_password
  attr_writer :cipher_password

  class << self
    def create(plain_text_password:)
      new(plain_text_password:)
    end

    def from_hash(password_hash)
      new.tap do |password|
        password.cipher_password = BCrypt::Password.new(password_hash)
      end
    end

    def with_cost(cost)
      old_cost = BCrypt::Engine.cost
      BCrypt::Engine.cost = cost
      yield
    ensure
      BCrypt::Engine.cost = old_cost
    end
  end

  def initialize(plain_text_password: nil)
    @plain_text_password = plain_text_password
  end

  def ==(other_password)
    case other_password
    in Password
      cipher_password == other_password.plain_text_password ||
        cipher_password == other_password.cipher_password
    in String
      cipher_password == other_password
    in BCrypt::Password
      cipher_password == other_password
    end
  end

  def hash
    cipher_password.to_s
  end

  def cipher_password
    @cipher_password ||= BCrypt::Password.create(plain_text_password)
  end
end
