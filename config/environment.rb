# File to setup common environment

require_relative 'init'

App = Struct.new(:root_path, :environment).new
App.root_path = Pathname(__FILE__).parent.parent.expand_path
