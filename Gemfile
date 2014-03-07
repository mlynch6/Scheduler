source 'https://rubygems.org'

gem 'rails', '3.2.13'		#matches version on Hostmoster
gem 'bootstrap-will_paginate', :git => 'git://github.com/yrgoldteeth/bootstrap-will_paginate.git'	#works with Bootstrap 3
gem 'validates_timeliness', '~> 3.0'
gem 'jquery-rails'
gem 'less-rails'
gem 'therubyracer'
gem 'prawn'
gem 'faker', '1.2.0'
gem 'fullcalendar-rails', '~>1.6.4'

# Subscription payment processing
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

group :development, :test do
  gem 'sqlite3', '1.3.5'
  gem 'rspec-rails', '~> 2.10.0'
  gem 'guard-rspec', '0.5.5'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.2.3'
  gem 'bootstrap-sass', '~> 3.0.3.0'		# Bootstrap 3
  gem 'jquery-ui-rails'
  gem 'chosen-rails'
end

group :development do
  gem 'annotate', '~> 2.5.0'
  gem 'populator', '1.0.0'
  #gem 'bullet'													# Performance
end

group :test do
  gem 'capybara',		'~> 2.2.1'
  gem 'selenium-webdriver', '~> 2.39.0'
  gem 'database_cleaner', '~> 1.2.0'
  gem 'rb-fsevent', '0.9.1', :require => false
  gem 'growl', '1.0.3'
  gem 'guard-spork', '0.3.2'
  gem 'spork', '0.9.0'
  gem 'factory_girl_rails', '1.4.0'
end

group :production do
end

# Use postgreSQL for production
gem 'pg', '~>0.12.2'
gem 'activerecord-postgresql-adapter'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.1'

# To use Jbuilder templates for JSON
gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn', '~> 4.7.0'

# Deploy with Capistrano
gem 'capistrano', '~> 3.0.1'
gem 'capistrano-rails', '~> 1.1.0'
gem 'capistrano-bundler'

# To use debugger
# gem 'debugger'
