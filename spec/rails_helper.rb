# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'capybara'
require 'capybara-screenshot/rspec'
require 'capybara/email/rspec'
require 'rspec/rails'
require 'shoulda/matchers'
require 'cancan/matchers'
require 'pry-byebug'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}
Dir[File.dirname(__FILE__) + "/models/concerns/*.rb"].each {|f| require f}
Dir[File.dirname(__FILE__) + "/controllers/concerns/*.rb"].each {|f| require f}
Dir[File.dirname(__FILE__) + "/api/v1/concerns/*.rb"].each {|f| require f}

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.include JsonSpec::Helpers

  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include ControllerMacros, type: :controller
  config.include ActiveJob::TestHelper
end



Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    with.library :rails
  end
end

OmniAuth.config.test_mode = true