# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

### Starting App

To start the rails app:
```bash
bundle install
source env.sh
rails s
```

For development, you would also need to start webpack dev server (in a separate terminal window). To start the webpack dev server:
```bash
brew install yarn
yarn install
./bin/webpack-dev-server
```
