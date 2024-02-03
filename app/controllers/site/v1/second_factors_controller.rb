# frozen_string_literal: true

module Site
  module V1
    # Controller to handle SecondFactor objects
    class SecondFactorsController < BaseController
      namespace '/site/v1' do
        get '/two_factors/show/:authenticated_code' do
          content = AuthenticatedUrl.get_content(params[:authenticated_code])
          if content.to_s.strip.empty?
            'Not found'
          else
            content
          end
        end
      end
    end
  end
end
