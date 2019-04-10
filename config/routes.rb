Rails.application.routes.draw do

  scope 'demo/api', controller: 'application', :format => false do
    get '/health-checker' => :health_checker
  end

  scope 'demo/api/setup', controller: 'setup/token', :format => false do
    match 'create-token' => :create, via: :POST
    match 'update-token' => :update, via: :POST
  end

  scope 'demo/api/:ost_token_id/:url_id', controller: 'api/authentication', :format => false do
    match 'signup' => :signup,  via: :POST
    match 'login' => :login, via: :POST
  end

  scope 'demo/api/:ost_token_id/:url_id/notify', controller: 'api/mobile/notify', :format => false do
    match 'user-activate' => :user_activate,  via: :POST
  end

  scope 'demo/api/:ost_token_id/:url_id/users', controller: 'api/token_user', :format => false do
    match '' => :list, via: :GET
    match 'logout' => :logout, via: :POST
  end

  scope 'demo/api/:ost_token_id/:url_id/users/:token_user_id/devices', controller: 'api/mobile/device', :format => false do
    match '' => :register, via: :POST
  end

  match '*permalink', to: 'application#not_found', via: :all

end
