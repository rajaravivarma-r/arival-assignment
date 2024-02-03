# frozen_string_literal: true

module Site
  module V1
    # BaseController for all site rendering controllers
    class BaseController < Sinatra::Base
      register Sinatra::Namespace

      before do
        content_type 'text/html'
      end
    end
  end
end
