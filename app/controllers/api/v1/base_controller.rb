# frozen_string_literal: true

# Analogous to ApplicationController in Rails
# Add useful helper methods to this base class, and add common
# behaviour that all other controllers should have.
module Api
  class BaseController < Sinatra::Base
    register Sinatra::Namespace
    NAMESPACE = '/api/v1'

    before do
      content_type :json
    end

    private

    def json_request_body
      # Convert to snake_case if required
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      error = AppError.new(
        field: 'request',
        error_messages: 'Invalid JSON request'
      )
      failure_json(status: 400, errors: error)
    end

    def success_json(status:, value:)
      status(status)
      { data: value }.to_json
    end

    def failure_json(status:, errors:)
      status(status)
      errors = Array(errors)
      error_response = { errors: errors.map(&:to_h) }
      error_response.to_json
    end
  end
end
