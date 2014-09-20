#The Venmo API Gem

A Ruby interface to the Venmo Developer API.

## Installation
  Add to your `Gemfile`:

  ```ruby
  gem "venmo-api"
  ```

  Then `bundle install`

## Google API Setup

* Go to 'https://venmo.com/'
* Login
* Click 'Account' in the navbar
* Select the developers pane/tab
* Click 'new' next to 'Your Applications'
* Fill in your app's information

##Usage
  Add to /config/initializers/venmo-api_initializer.rb. (You should create this file if it doesn't exist)
  ```ruby
  Rails.application.config.before_initialize do
    ::Venmo = VenmoAPI::Client.new do |config|
      config.client_id = 'VENMO_CLIENT_ID'
      config.secret = 'VENMO_CLIENT_SECRET'
      config.scope = ['make_payments', 'access_feed', 'access_profile', 'access_email', 'access_phone', 'access_balance', 'access_friends']
      config.response_type = 'code'
    end
  end
  ```

  You can now access the Venmo-API Client object: `Venmo`


## Examples
  https://github.com/akhor93/venmo-api-example