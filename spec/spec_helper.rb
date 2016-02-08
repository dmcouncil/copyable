$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_support/all'
require 'active_support/testing/time_helpers'
require 'database_cleaner'

Bundler.require(:default, :test)

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

end

