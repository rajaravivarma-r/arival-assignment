module Validators
  module RequestData
    class NewUserContract < Dry::Validation::Contract
      params do
        required(:email).filled(:string)
        required(:password).filled(:string)
        required(:password_verification).filled(:string)
      end

      rule(:email) do
        key.failure('has invalid format') unless /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i.match?(value)
      end

      rule(:password, :password_verification) do
        key.failure('should match password_verification') if values[:password] != values[:password_verification]
      end
    end
  end
end
