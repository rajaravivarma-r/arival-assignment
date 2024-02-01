# frozen_string_literal: true

# Controller to handle new user registration
class UserRegistrationController < Sinatra::Base
  post '/users' do
    result = RegisterNewUser.call(**json_request_body)
  end
end
