source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :production do
  gem 'mysql2'
  gem 'passenger'
  # gem 'activerecord-mysql2-adapter'
end

# User authentication
gem 'devise'
gem 'omniauth', git: 'git://github.com/intridea/omniauth.git'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-paypal', git: 'git://github.com/datariot/omniauth-paypal.git'
gem 'omniauth-dwolla', git: 'git://github.com/austingulati/omniauth-dwolla.git'
gem 'omniauth-wepay', git: 'git://github.com/tenaciousflea/omniauth-wepay.git'

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
gem 'ransack'
gem 'will_paginate'
gem 'bootstrap-will_paginate'

# Web server
gem 'thin'

# Emails
gem 'roadie'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'actionmailer-callbacks'
gem 'mail_form'

# Linking chat urls
gem 'rinku'

# Javascript
gem 'js-routes'

# Payments
gem 'active_paypal_adaptive_payment', git: 'git://github.com/austingulati/active_paypal_adaptive_payment.git'
gem 'dwolla', git: 'git://github.com/austingulati/dwolla-ruby.git'
gem 'wepay', git: 'git://github.com/wepay/Ruby-SDK.git'

# Monitoring
gem 'newrelic_rpm'

# Pretty URLs
gem 'friendly_id'

# PDF Generation
gem 'prawn', git: 'git://github.com/celic/prawn.git', submodules: true

# QR Code Generation
gem 'rqrcode'

# ActiveRecord extensions
gem "activerecord-import"

group :development, :test do
  gem 'sqlite3'
end

group :development do
  gem 'annotate'
  gem 'quiet_assets'
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
  gem 'shoulda-matchers', '1.5.2'
end

# Gems used only for assets and not required
# in production environments by default.
# group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'bourbon'
  gem 'bootstrap-sass', git: 'git://github.com/austingulati/bootstrap-sass.git' # path: '/var/www/bootstrap-sass'
  gem 'mustache'
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
gem 'fog', git: 'git://github.com/fog/fog.git'

# To use debugger
# gem 'debugger'
