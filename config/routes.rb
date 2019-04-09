Rails.application.routes.draw do

  scope '', controller: 'application', :format => false do
    get '/health-checker' => :health_checker
  end

  scope 'setup/token', controller: 'setup/token', :format => false do
    match 'create' => :create, via: :POST
    match 'update' => :update, via: :POST
  end

  scope 'api/:url_id/:ost_token_id', controller: 'api/authentication', :format => false do
    match 'signup' => :signup,  via: :POST
    match 'login' => :login, via: :POST
  end

  scope 'api/:url_id/:ost_token_id/users', controller: 'api/token_user', :format => false do
    match '' => :list, via: :GET
  end

  scope 'api/:url_id/:ost_token_id/users/:token_user_id/devices', controller: 'api/mobile/devices', :format => false do
    match '' => :register_device, via: :POST
  end

  # Route not found handler. Should be the last entry here
  match '*permalink', to: 'application#not_found', via: :all

end