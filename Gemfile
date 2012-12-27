source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :production do
  gem 'mysql2'
  # gem 'activerecord-mysql2-adapter'
end

# User authentication
gem 'devise'
gem 'omniauth-twitter'
gem 'omniauth-facebook'

# User profiles
gem 'gravatar_image_tag'
gem 'paperclip'

# Configuration
gem 'figaro'

# Transactions
gem 'money-rails'

# Validations
gem 'date_validator', git: 'git://github.com/codegram/date_validator.git'

# Dates
gem 'american_date'

# Searching
gem "ransack"

# Web server
gem 'thin'

# Emails
gem 'roadie'
gem 'delayed_job_active_record'
gem 'daemons'

group :development, :test do
  gem 'sqlite3'
end

group :development do
  gem 'annotate'
end

group :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'capybara', '1.1.2'
  gem 'spork'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'rb-inotify', '~> 0.8.8'
  gem 'delorean'
end

# Gems used only for assets and not required
# in production environments by default.
# group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'bootstrap-sass', git: 'git://github.com/austingulati/bootstrap-sass.git' # path: '/var/www/bootstrap-sass'
  # gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
# end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

# To use debugger
# gem 'debugger'
