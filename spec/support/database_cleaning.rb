# frozen_string_literal: true

# require 'database_cleaner_sequel'
# require 'database_cleaner'

DatabaseCleaner[:sequel].strategy = :transaction

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:sequel].start
  end

  config.before do
    DatabaseCleaner[:sequel].start
  end

  config.after do
    DatabaseCleaner[:sequel].clean
  end
end
