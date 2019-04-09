source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2', '>= 5.2.2.1'
# Rake file
gem 'rake', '12.3.2'
# Use mysql2 as the database for Active Record
gem 'mysql2', '0.5.2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# YUI compressor
gem 'yui-compressor', '0.12.0'
# Webpacker
gem 'webpacker', '~> 4.0.2'

# Json formatter
gem 'oj', '3.3.8'
# Sanitize params
gem 'sanitize', '5.0.0'
# AWS KMS
gem 'aws-sdk-kms', '1.13.0'
# Memcache
gem 'dalli', '2.7.9'
# OST SDK
gem 'ost-sdk-ruby', '2.0.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'pry'
end

group :test do
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]