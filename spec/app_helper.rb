# frozen_string_literal: true

require_relative '../config/environments/test'

App.load_app_code!

require 'sidekiq/testing'
Sidekiq::Testing.fake!

spec_support_path = App.config.root_path.join('spec/support')

spec_support_path.join('helpers').glob('**/*.rb').sort.each do |f|
  require f
end
spec_support_path.join('shared_context').glob('**/*.rb').sort.each do |f|
  require f
end
spec_support_path.join('shared_examples').glob('**/*.rb').sort.each do |f|
  require f
end
spec_support_path.glob('**/*.rb').sort.each do |f|
  require f
end

RSpec.configure do |config|
  config.include(TestRequestHelpers)
  config.include(TestResponseHelpers)

  config.example_status_persistence_file_path = App.config.root_path.join('tmp/rspec')
end
