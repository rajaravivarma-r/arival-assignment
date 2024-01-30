require 'app_helper'

RSpec.describe UserRegistrationController do
  def app
    UserRegistrationController
  end

  describe 'user registration' do
    it 'allows user to register themselves' do
      post(
        '/users',
        JSON.generate({ email: 'user@example.com', password: 'SecurePasswd*10' }),
        { 'CONTENT_TYPE' => 'application/json' }
      )
      puts last_response.body
    end
  end
end
