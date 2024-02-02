# frozen_string_literal: true

# Set of helper functions to send uniform responses
module ResponseHelper
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
