module Validators
  module RequestData
    class NewUserContract < Dry::Validation::Contract
      REQUIRED_KEYS = %i[email password password_verification]
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

      attr_reader :json_data, :errors

      # def initialize(json_data)
      #   @json_data = json_data
      #   @errors = []
      # end

      # def valid?
      #   unless (key_errors = validate_keys).empty?
      #     @errors += key_errors
      #     false
      #   end
      #   return unless (password_verification_error = verify_password_verification_match)

      #   @errors << password_verification_error
      #   false
      # end

      # private

      # def validate_keys
      #   REQUIRED_KEYS.map do |key|
      #     { field: key, error: 'missing' } unless json_data.key?(key)
      #   end
      # end

      # def verify_password_verification_match
      #   return if json_data[:password] == json_data[:password_verification]

      #   { field: :password, error: 'does not match password_verification' }
      # end
    end
  end
end
