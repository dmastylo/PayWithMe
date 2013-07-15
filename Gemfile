source 'https://rubygems.org'

# Core
gem 'rails', '3.2.13.rc2'
gem 'thin'
gem 'figaro'

# Data
group :production do
  gem 'mysql2'
  gem 'passenger'
end
group :development, :test do
  gem 'sqlite3'
end
gem 'ransack'

# Payments
gem 'balanced'

# Localization
gem 'american_date'

# Authentication
gem 'devise'
gem 'omniauth', git: 'git://github.com/intridea/omniauth.git'
gem 'omniauth-twitter'
gem 'omniauth-facebook'

# Helpers
gem 'gravatar_image_tag', git: 'git://github.com/mdeering/gravatar_image_tag.git'
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'rinku'
gem 'nested_form'

# Model
gem 'paperclip'
gem 'money-rails'
gem 'date_validator', git: 'git://github.com/codegram/date_validator.git'
gem "activerecord-import"

# Mailers
gem 'roadie'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'actionmailer-callbacks'
gem 'mail_form'

# Javascript
gem 'js-routes'

# Util
gem 'newrelic_rpm'
gem 'friendly_id'
gem 'vanity', git: 'git://github.com/austingulati/vanity.git'
gem 'prawn', git: 'git://github.com/celic/prawn.git', submodules: true
group :development do
  gem 'annotate'
  gem 'quiet_assets'
end

# Test
group :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'capybara', '1.1.2'
  gem 'spork'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'rb-inotify', '~> 0.9'
  gem 'delorean'
  gem 'shoulda-matchers', '1.5.2'
end

# Frontend
gem 'sass-rails',   '~> 3.2.3'
gem 'bourbon'
gem 'bootstrap-sass', git: 'git://github.com/austingulati/bootstrap-sass.git'
gem 'mustache'
gem 'coffee-rails', '~> 3.2.1'
gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails'
gem 'angularjs-rails'

# Deployment
gem 'capistrano'
gem 'rvm-capistrano'
gem 'fog', git: 'git://github.com/fog/fog.git'

# Sellers
# gem 'ordrin', path: '../api-ruby' # git: 'git@github.com:austingulati/api-ruby.git'