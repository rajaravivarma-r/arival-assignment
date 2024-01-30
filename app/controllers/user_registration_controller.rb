# frozen_string_literal: true

# Controller to handle new user registration
class UserRegistrationController < Sinatra::Base
  post '/users' do
    new_user_contract = Validators::RequestData::NewUserContract.new
    new_user_contract.call(json_request_body)
  end
end
