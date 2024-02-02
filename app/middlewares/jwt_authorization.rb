# frozen_string_literal: true

# Middleware to authorize using JWTs
class JWTAuthorization
  include ResponseHelper

  def initialize(app)
    @app = app
  end

  def call(env)
    bearer = env.fetch('HTTP_AUTHORIZATION', '').split[1]&.strip
    env[:current_user] = UserSessionToken.get_user(bearer)
    @app.call(env)
  rescue JWT::ExpiredSignature
    error_response(
      status: 403, error_message: 'The token has expired.'
    )
  rescue JWT::DecodeError
    error_response(
      status: 401, error_message: 'A token must be passed.'
    )
  rescue JWT::InvalidIssuerError
    error_response(
      status: 403, error_message: 'The token does not have a valid issuer.'
    )
  rescue JWT::InvalidIatError
    error_response(
      status: 403, error_message: 'The token does not have a valid "issued at" time.'
    )
  end

  private

  def error_response(status:, error_message:)
    [
      status,
      { Header::CONTENT_TYPE => ContentType::APPLICATION_JSON },
      failure_json_body(token_error(error_message))
    ]
  end

  def token_error(message)
    AppError.new(field: 'token', error_messages: message)
  end
end
