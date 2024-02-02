# frozen_string_literal: true

module Api
  module V1
    # Handles user data
    class UsersController < BaseController
      use JWTAuthorization

      namespace NAMESPACE do
        put '/users/update' do
          result = UpdateUser.new(
            user: current_user, updated_attributes: json_request_body['user']
          ).call
          if result.success?
            serialized_user = JsonSerializers::UserSerializer.serialize(
              result.value
            )
            success_json(status: 200, value: serialized_user)
          else
            failure_json(status: 400, errors: result.errors)
          end
        end
      end
    end
  end
end
