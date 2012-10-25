source 'https://rubygems.org'

# Main
gem 'rails', '3.2.3'

# Testing
gem 'rspec-rails'
gem 'factory_girl_rails'

# User Authentication
gem 'devise'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-dwolla', git: 'git://github.com/jeffersongirao/omniauth-dwolla.git'
# gem 'omniauth-paypal'

# Payment Processing
gem 'dwolla'

# Database and Models
gem 'squeel'
gem 'annotate'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3', :group => [:development, :test]
gem 'quiet_assets', :group => :development
gem 'thin', :group => :development
group :production do
  gem 'thin'
  gem 'pg'
end

# Gems used only for assets and not required
# in production environments by default.
gem 'twitter-bootstrap-rails', git: 'git://github.com/austingulati/twitter-bootstrap-rails.git'
gem 'jquery-rails'
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'