# frozen_string_literal: true

require_relative '../config/environments/test'

App.config.root_path.glob('app/**/*.rb').sort.each { |f| require f }
