require 'bundler/setup'

require 'mongoid_delorean' # and any other gems you need

require 'database_cleaner'

Mongoid.load!(File.join(File.dirname(__FILE__), "config.yml"), :test)
require File.join(File.dirname(__FILE__), "support", "models")

DatabaseCleaner[:mongoid].strategy = :truncation

RSpec.configure do |config|

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

end