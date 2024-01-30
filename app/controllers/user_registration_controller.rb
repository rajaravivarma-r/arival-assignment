require 'json'

class UserRegistrationController < Sinatra::Base
  post '/users' do
    case json_body
    in { email: String, password: String, password_verification: String }
    else
      raise InvalidRequestError, 'Request body not in acceptable format'
    end
  end
end
