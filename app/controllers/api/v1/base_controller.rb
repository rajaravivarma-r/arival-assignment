# frozen_string_literal: true

module Api
  # Analogous to ApplicationController in Rails
  # Add useful helper methods to this base class, and add common
  # behaviour that all other controllers should have.
  class BaseController < Sinatra::Base
    include ::ResponseHelper

    register Sinatra::Namespace
    NAMESPACE = '/api/v1'

    before do
      content_type :json
    end

    private

    def current_user
      env[:current_user]
    end

    def json_request_body
      # Convert to snake_case if required
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      error = AppError.new(
        field: 'request',
        error_messages: 'Invalid JSON request'
      )
      halt(400, Header.json_content_type, failure_json_body(error))
    end
  end
end
