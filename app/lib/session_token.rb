# frozen_string_literal: true

# Abstracts the mechanisms to work with JWT tokens
class SessionToken
  attr_reader(
    :private_sign_key,
    :public_sign_key,
    :sign_algorithm,
    :payload,
    :token_string
  )

  def initialize(
    private_sign_key: App.config.secret.jwt_sign_private_key,
    public_sign_key: App.config.secret.jwt_sign_public_key,
    sign_algorithm: App.config.secret.jwt_sign_algorithm
  )
    @private_sign_key = private_sign_key
    @public_sign_key = public_sign_key
    @sign_algorithm = sign_algorithm
  end

  def encode_to_string(payload:)
    encode(payload).token_string
  end

  def decode_payload(token_string:)
    decode(token_string).payload
  end

  private

  def encode(payload)
    @payload = payload
    @token_string = JWT.encode(payload, private_sign_key, sign_algorithm)
    self
  end

  def decode(token_string)
    @token_string = token_string
    @payload = JWT.decode(
      token_string, public_sign_key, true, { algorithm: sign_algorithm }
    )
    self
  end
end
