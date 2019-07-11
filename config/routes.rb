Rails.application.routes.draw do

  scope 'demo/api', controller: 'application', :format => false do
    get '/health-checker' => :health_checker
  end

  scope 'demo/api', controller: 'setup/token', :format => false do
    match 'setup/create-token' => :create, via: :POST
    match 'setup/update-token' => :update, via: :POST
    match 'token-stats' => :get_token_stats, via: :GET
  end

  scope 'demo/api/ost-event', controller: 'api/event', :format => false do
    match '' => :ost_event, via: :POST
  end

  scope 'demo/api/:ost_token_id/:url_id', controller: 'api/authentication', :format => false do
    match 'signup' => :signup,  via: :POST
    match 'login' => :login, via: :POST
  end

  scope 'demo/api/:ost_token_id/:url_id/token', controller: 'api/token', :format => false do
    match '' => :get,  via: :GET
  end

  scope 'demo/api/:ost_token_id/:url_id/notify', controller: 'api/notify', :format => false do
    match 'user-activate' => :user_activate,  via: :POST
  end

  scope 'demo/api/:ost_token_id/:url_id/users', controller: 'api/token_user', :format => false do
    match 'logout' => :logout, via: :POST
    match 'current-user' => :logged_in_user_detail, via: :GET
    match 'current-user-salt' => :logged_in_user_salts, via: :GET
    match 'ledger' => :logged_in_user_ledger, via: :GET
    match '' => :list, via: :GET
  end

  scope 'demo/api/:ost_token_id/:url_id/users/:app_user_id', controller: 'api/token_user', :format => false do
    match 'detail' => :get_detail, via: :GET
    match 'balance' => :get_balance, via: :GET
    match 'set-preference' => :set_crashlytics_preference, via: :POST
    match 'get-preference' => :get_crashlytics_preference, via: :GET
  end

  scope 'demo/api/:ost_token_id/:url_id/devices', controller: 'api/device', :format => false do
    match '' => :register, via: :POST
    match '' => :list, via: :GET
  end

  %w( 404 400 422 500 ).each do |code|
    match code, controller: :application, action: :error, :format => false, code: code, via: [:GET, :POST]
  end

end
