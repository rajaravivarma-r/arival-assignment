# frozen_string_literal: true

# Set of helper functions to send uniform responses
module ResponseHelper
  # Header name constants
  module Header
    CONTENT_TYPE = 'Content-Type'

    def self.json_content_type
      { CONTENT_TYPE => ContentType::APPLICATION_JSON }
    end
  end

  # Header value constants
  module ContentType
    APPLICATION_JSON = 'application/json'
  end

  def success_json(status:, value:)
    status(status)
    success_json_body(value)
  end

  def failure_json(status:, errors:)
    status(status)
    failure_json_body(errors)
  end

  def success_json_body(value)
    { data: value }.to_json
  end

  def failure_json_body(errors)
    errors = Array(errors)
    error_response = { errors: errors.map(&:to_h) }
    error_response.to_json
  end
end
