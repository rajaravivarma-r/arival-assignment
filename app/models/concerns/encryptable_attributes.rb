# frozen_string_literal: true

# Used to handle attributes of models that are encrypted in database
module EncryptableAttributes
  def encrypts(attribute, to:)
    encrypted_column = to

    define_method(attribute) do
      encrypted_value = send(encrypted_column)
      self.class.decrypt_and_verify(encrypted_value) unless encrypted_value.nil?
    end

    define_method("#{attribute}=") do |value|
      encrypted_data = self.class.encrypt_and_sign(value)
      send("#{encrypted_column}=", encrypted_data)
    end
  end

  def decrypt_and_verify(encrypted_data)
    crypt.decrypt_and_verify(encrypted_data)
  end

  def encrypt_and_sign(value)
    crypt.encrypt_and_sign(value.to_s)
  end

  def crypt
    ActiveSupport::MessageEncryptor.new(App.config.secret.data_encryption_key)
  end
end
