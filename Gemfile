source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '3.2.13'

# Postgres
gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # Set at this version to fix EOFError
  gem 'sass', '= 3.1.19'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :require => 'v8'

  gem 'uglifier', '>= 1.0.3'

  # Must use older version to fix error with capybara-webkit testing
  gem 'twitter-bootstrap-rails', '= 2.0.8'
  gem 'handlebars_assets'
  gem 'bourbon'
end

# JavaScript
gem 'jquery-rails'
gem 'backbone-on-rails', '= 0.9.2.1'
gem 'bootstrap-wysihtml5-rails'

# Security
gem 'strong_parameters'

# Authentication
gem 'omniauth'
gem 'omniauth-twitter'
gem 'cancan'

# To use Jbuilder templates for JSON
gem 'jbuilder'

# Voting
gem 'thumbs_up'

# Enumerations for Rails
gem 'simple_enum'

# Load the environment from application.yml
gem 'figaro'

group :development do
  gem 'sqlite3'

  gem 'irbtools-more'
  gem 'annotate'

  # Provisioning
  gem 'teleport'
  # Deploymenet
  gem 'mina'
end

group :test, :development do
  # Make log output easier to read
  gem 'quiet_assets'
end

group :test do
  # Capybara
  gem 'capybara'
  gem 'minitest-capybara'
  # Allows for js: true flag to be processed on tests
  gem 'minitest-metadata'
  # Run tests in a hidden webkit instance
  gem 'capybara-webkit'
  # Show screenshots when tests fail
  gem 'capybara-screenshot'
  gem 'launchy'

  # Clean the database so we don't hit name conflicts
  gem 'database_cleaner'
  # For creating objects without fixtures
  gem 'fabrication'
  # Creates text strings of various predefined types
  gem 'ffaker'

  # Minitest
  gem 'minitest-rails'
  # Run tests whenever relevant files are modified
  gem 'guard-minitest', git: 'https://github.com/singlebrook/guard-minitest.git', branch: 'spork_incompatible_args'
  # Run tests on a server to keep from reloading rails every time
  gem 'spork-minitest', '~> 0.0.2'
end
