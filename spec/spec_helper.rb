ENV["RACK_ENV"] = "test"
require "factory_girl"
require "capybara"
require "rack/test"
require File.expand_path '../../config/boot.rb', __FILE__
require File.expand_path '../factories/transaction_factory.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  include Capybara::DSL

  def app() 
    eval "Rack::Builder.new {( " + File.read(File.dirname(__FILE__) + '/../config.ru') + "\n )}"
  end
end

RSpec.configure { |c| c.include RSpecMixin }

