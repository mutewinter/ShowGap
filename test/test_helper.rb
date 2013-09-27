require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)

  # -----------------------
  # Minitest
  # -----------------------

  require "minitest/autorun"
  require "minitest/rails"
  # Colorful test output
  require "minitest/pride"
  require 'capybara/rails'


  # Fixed port so we can change the host for a specific subdomain.
  Capybara.server_port = 13261
  Capybara.javascript_driver = :webkit

  # Necessary for sqlite since it doesn't support transactions
  DatabaseCleaner.strategy = :truncation

end

Spork.each_run do
  # This code will be run each time you run your specs.
  require File.expand_path('../../test/acceptance_test', __FILE__)

  # Setup OmniAuth for fake twitter login
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:twitter] = {
    provider: 'twitter',
    uid: rand(100000000)
  }
end
