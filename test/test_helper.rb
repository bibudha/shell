ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

gem 'mocha'
require 'mocha'

gem 'ruby-openid'
require 'openid'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
  
  def self.helper_method(*args); end
  
  include AuthenticatedTestHelper
  include AuthenticatedSystem
  include UserOpenidsHelper
end
