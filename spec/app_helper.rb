require_relative '../config/environments/test'

App.root_path.glob('app/**/*.rb').sort.each { |f| require f }
