# frozen_string_literal: true

module TestRequestHelpers
  def json_put(route, body, headers = {})
    json_body = body.to_json unless body.is_a?(String)
    updated_headers = headers.merge('CONTENT_TYPE' => 'application/json')
    put route, json_body, updated_headers
  end
end
