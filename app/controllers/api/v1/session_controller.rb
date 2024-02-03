# frozen_string_literal: true

module Api
  module V1
    # Controller to handle new user registration
    class SessionController < BaseController
      namespace NAMESPACE do
        post '/login' do
          result = LoginStrategy.execute(
            **json_request_body.transform_keys(&:to_sym)
          )
          if result.success?
            token = UserSessionToken.issue(result.value)
            success_json(status: 200, value: { token: })
          else
            failure_json(status: 401, errors: result.errors)
          end
        end
      end
    end
  end
end
