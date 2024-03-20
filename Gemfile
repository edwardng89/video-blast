source 'https://rubygems.org'
gem 'cancancan'
gem 'classy_enum'
gem 'database_cleaner'
gem 'devise'
gem 'devise_invitable'
gem 'devise_zxcvbn'
gem 'draper'
gem 'dropzonejs-rails'
gem 'factory_bot_rails'
gem 'faker'
gem 'fog-aws'
gem 'has_scope'
gem 'jquery-turbolinks'
gem 'mini_magick'
gem 'money-rails'
gem 'mosaico', github: 'mindvision/mosaico-rails', branch: 'master'
gem 'nested_form'
gem 'paranoia'
gem 'phonelib'
gem 'quick_edit', git: 'ssh://gerrit.mindvision.com.au/lib/mvi-admin/quick-edit'
gem 'rails_sortable' # TODO: situational
gem 'rspec-rails'
gem 'sidekiq', '< 7'
gem 'simple_form'
gem 'userstamper', github: 'mindvision/userstamper'
# gem 'fog-aws' # Was getting a duplicate in Elite
gem 'awesome_nested_set'
gem 'country_select'
gem 'momentjs-rails' # TODO: change to CDN
gem 'mvi_validators', git: 'ssh://gerrit.mindvision.com.au/lib/mvi_validators'
gem 'spinjs-rails' # TODO: change to CDN

# used for breadcrumbs in replacement of crummy
gem 'breadcrumbs_on_rails'

# Excel
gem 'axlsx', github: 'randym/axlsx', branch: 'master'

gem 'kaminari'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'rails-controller-testing'

  # Help limit n+1 in development and testing
  # If we get false positives switch to Prosopite which handles false postives better but isn't as descriptive
  gem 'bullet' # rails g bullet:install
  # gem 'prosopite'
  # gem 'pg_query'
end

group :development do
  gem 'letter_opener'
  gem 'xray-rails', git: 'https://github.com/brentd/xray-rails.git', branch: 'bugs/ruby-3.0.0'
end

group :production, :preview do
  gem 'mvi_production', git: 'ssh://gerrit.mindvision.com.au/lib/mvi_production', branch: 'rails-6'

  gem 'rack-mini-profiler', '~> 2.0'

  # Graylog for production server logs
  gem 'gelf'
  gem 'lograge'
end

gem 'ruby-progressbar'

##
# Required for boolean label handling
gem 'human_attributes', git: 'https://github.com/mindvision/human_attributes.git', branch: 'master'

##
# For snippet overriding
gem 'deface'

##
# For redis related storage
gem 'redis-namespace'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'

# Used for accessing private S3 buckets
gem 'aws-sdk-s3'

# Restrict Sprockets version until ready to change over to webpacker for rails 6
gem 'sprockets', '< 4'

# For emails tokens used within the letter templates
gem 'liquid'

# Used for image/file uploading
gem 'carrierwave'

gem 'net-smtp', require: false

# HTML code formatters
gem 'htmlbeautifier'
gem 'rubocop'
gem 'rubocop-rails', require: false

# Needed for seeds
gem 'faraday'
gem 'roo'

# Methods to define a calendar
gem 'simple_calendar'

# Code Editor Syntax Highlighting
gem 'ace-rails-ap'

# For watchdog
gem 'client_side_validations-simple_form'
gem 'listen'
# To read config/application.yml for environment variables
gem 'client_side_validations'
gem 'figaro', git: 'https://github.com/ffdd/figaro.git', branch: 'main'

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '>= 4.0.1'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
gem 'sassc-rails'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
end
