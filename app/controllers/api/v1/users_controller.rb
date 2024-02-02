# frozen_string_literal: true

module Api
  module V1
    # Handles user data
    class UsersController < BaseController
      use JWTAuthorization

      namespace NAMESPACE do
        put '/update' do
          require 'byebug'; byebug
        end
      end
    end
  end
end
