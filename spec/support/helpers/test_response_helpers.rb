# frozen_string_literal: true

module TestResponseHelpers
  def last_response_json
    JSON.parse(last_response.body)
  end
end
