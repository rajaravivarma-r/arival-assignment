# frozen_string_literal: true

require_relative 'config/environment'

App.load_current_environment!
App.load_app_code!

# AppContainer to use all controllers
class AppContainer < Sinatra::Base
  use Api::V1::UserRegistrationController
  use Api::V1::SessionController
  use Api::V1::UsersController
  use Api::V1::SecondFactorsController
  use Site::V1::SecondFactorsController
end

run AppContainer
