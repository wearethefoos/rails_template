source 'http://rubygems.org'

gem 'rails'
gem 'thin'

gem 'mongoid', :git => 'https://github.com/mongoid/mongoid.git'
gem 'bson_ext'
gem "mongoid_rails_migrations"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'
gem 'sprockets'

gem 'devise'
gem 'cancan'
gem "omniauth"
gem 'oa-openid'

gem 'carrierwave'
gem 'carrierwave-mongoid'
gem 'fog'
gem 'mini_magick'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'rspec-rails', :group => [:test, :development]
group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'spork'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-spork'
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard' # for Mac OS X 10.8
  # gem 'growl'       # for Mac OS X,
  # gem 'notifu'    # for Windows
  # gem 'libnotify' # for Linux + Gnome
  gem 'mongoid-rspec', :require => false
  gem 'database_cleaner'
  gem 'launchy'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'heroku'
  gem 'turn', :require => false
end
