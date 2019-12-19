Rails.application.routes.draw do

  # To Monitor the health of application
  scope 'demo/api', controller: 'application', :format => false do
    get '/health-checker' => :health_checker
  end

  # Routes to setup multiple test economies for OST Wallet app
  scope 'demo/api', controller: 'setup/token', :format => false do
    match 'setup/create-token' => :create, via: :POST
    match 'setup/update-token' => :update, via: :POST
    match 'token-stats' => :get_token_stats, via: :GET
  end

  # Webhook URL subscribed in OST to receive events for test economies and user wallets.
  # We love webhooks as they save backend server resources :)
  # To get a list of all available webhooks please refer: https://dev.ost.com/platform/docs/api/#webhook-topics
  scope 'demo/api/ost-wallet-test-webhook', controller: 'api/event', :format => false do
    match '' => :ost_event, via: :POST
  end

  # login/signup routes for OST Wallet app
  scope 'demo/api/:ost_token_id/:url_id', controller: 'api/authentication', :format => false do
    match 'signup' => :signup,  via: :POST
    match 'login' => :login, via: :POST
  end

  # Fetch OST registered token details
  scope 'demo/api/:ost_token_id/:url_id/token', controller: 'api/token', :format => false do
    match '' => :get,  via: :GET
  end

  # OST wallet notify backend once the wallet setup is completed
  # NOTE: There is a webhook for this notification
  scope 'demo/api/:ost_token_id/:url_id/notify', controller: 'api/notify', :format => false do
    match 'user-activate' => :user_activate,  via: :POST
  end

  # Logged in user routes
  scope 'demo/api/:ost_token_id/:url_id/users', controller: 'api/token_user', :format => false do
    match 'logout' => :logout, via: :POST
    match 'current-user' => :logged_in_user_detail, via: :GET
    match 'current-user-salt' => :logged_in_user_salts, via: :GET
    match 'ledger' => :logged_in_user_ledger, via: :GET
    match '' => :list, via: :GET
  end

  # Logged in user routes
  scope 'demo/api/:ost_token_id/:url_id/users/:app_user_id', controller: 'api/token_user', :format => false do
    match 'detail' => :get_detail, via: :GET
    # NOTE: current user balance can be fetched from wallet SDK as well.
    # For list of OST APIs available in wallet and server side SDK, please refer:
    # https://dev.ost.com/platform/docs/sdk/apis-in-sdks/
    match 'balance' => :get_balance, via: :GET
    match 'set-preference' => :set_crashlytics_preference, via: :POST
    match 'get-preference' => :get_crashlytics_preference, via: :GET
  end

  # User device routes
  scope 'demo/api/:ost_token_id/:url_id/devices', controller: 'api/device', :format => false do
    # NOTE: Register device can only be done by server side SDK.
    # For list of OST APIs available in wallet and server side SDK, please refer:
    # https://dev.ost.com/platform/docs/sdk/apis-in-sdks/
    match '' => :register, via: :POST
    # NOTE: Devices list can also be fetched from wallet SDK.
    # For list of OST APIs available in wallet and server side SDK, please refer:
    # https://dev.ost.com/platform/docs/sdk/apis-in-sdks/
    match '' => :list, via: :GET
  end

  %w( 404 400 422 500 ).each do |code|
    match code, controller: :application, action: :error, :format => false, code: code, via: [:GET, :POST]
  end

end
