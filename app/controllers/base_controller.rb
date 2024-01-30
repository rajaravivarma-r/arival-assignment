# frozen_string_literal: true

# Analogous to ApplicationController in Rails
# Add useful helper methods to this base class, and add common
# behaviour that all other controllers should have.
class BaseController < Sinatra::Base
  private

  def json_request_body
    # Convert to snake_case if required
    JSON.parse(request.body.read)
  rescue JSON::ParserError
    status 400
    error_json_response_body(message: 'Invalid JSON format')
  end

  def error_json_response_body(message:)
    error_response_body(message:).to_json
  end

  def error_response_body(message:)
    { error: { message: } }
  end
end
