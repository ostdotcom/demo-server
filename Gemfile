source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.2.1'
# Rake file
gem 'rake', '12.3.1'
# listen
gem 'listen', '3.1.5'
# Use mysql2 as the database for Active Record
gem 'mysql2', '0.5.2'

# Exception notifier
gem 'exception_notification', '4.3.0'

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

gem 'jwt', '2.2.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'pry'
  gem 'letter_opener'
end

group :test do
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]