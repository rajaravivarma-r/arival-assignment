# frozen_string_literal: true

# Controller to handle new user registration
module Api
  module V1
    class SessionController < BaseController
      post '/users' do
        result = RegisterNewUser.call(
          **json_request_body.transform_keys(&:to_sym)
        )
        if result.success?
          serialized_user = JsonSerializers::UserSerializer.serialize(
            result.value
          )
          success_json(status: 201, value: serialized_user)
        else
          failure_json(status: 400, errors: result.errors)
        end
      end
    end
  end
end
