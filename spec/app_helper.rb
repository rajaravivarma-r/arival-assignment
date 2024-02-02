# frozen_string_literal: true

require_relative '../config/environments/test'

App.load_app_code!

App.config.root_path.join('spec/support').glob('**/*.rb').sort.each do |f|
  require f
end
