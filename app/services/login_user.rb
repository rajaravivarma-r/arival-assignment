class LoginUser < BaseService
  attr_reader :email, :password

  class << self
    def call
    end
  end

  def initialize(email:, password:)
    @email = email
    @password = password
  end

  def call
    user = User.find(email: email)
    unless user
      error = construct_error(field: 'user', error_messages: 'cannot find user')
      return Result.failure(errors: error)
    end

    unless user.valid_password?(password)
      error = construct_error(field: 'user', error_messages: 'invalid password')
      return Result.failure(errors: error)
    end
    Result.success(value: user)
  end
end
