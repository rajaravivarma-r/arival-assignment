# frozen_string_literal: true

require 'app_helper'

RSpec.describe Api::V1::UsersController do
  def app
    described_class
  end

  it_behaves_like 'an authorized controller'

  describe 'PUT /update' do
    it 'updates the user object' do
    end
  end
end
