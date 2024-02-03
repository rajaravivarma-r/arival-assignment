# frozen_string_literal: true

module Api
  module V1
    # Controller to handle SecondFactor objects
    class SecondFactorsController < BaseController
      use JWTAuthorization

      namespace NAMESPACE do
        post '/two_factors/enable' do
          if (second_factor = current_user.second_factor)&.enabled?
            second_factor_json = serializer(second_factor)
                                 .as_json.except(:backup_codes)
            success_json(status: 200, value: second_factor_json)
          else
            second_factor = SecondFactor.enable_for_user(current_user)
            second_factor_json = serializer(second_factor).as_json(
              qr_code_authenticated_url: to('/site/v1/two_factors/show/%<code>s')
            )
            success_json(status: 201, value: second_factor_json)
          end
        end

        put '/two_factors/disable' do
          if (second_factor = current_user.second_factor)
            second_factor.disable!
            second_factor_json = serializer(second_factor)
                                 .as_json
                                 .except(:otp_secret, :backup_codes)
            success_json(status: 200, value: second_factor_json)
          else
            error = AppError.new(field: 'second_factor', error_messages: 'two factor authentication is not enabled')
            failure_json(status: 404, errors: error)
          end
        end
      end

      private

      def serializer(second_factor)
        JsonSerializers::SecondFactorSerializer.new(second_factor)
      end
    end
  end
end
