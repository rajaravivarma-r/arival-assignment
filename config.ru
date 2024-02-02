# frozen_string_literal: true

require_relative 'config/environment'

App.load_current_environment!
App.load_app_code!

class AppContainer < Sinatra::Base
  use Api::V1::UserRegistrationController
  use Api::V1::SessionController
  use Api::V1::UsersController
end

run AppContainer
