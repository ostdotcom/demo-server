Rails.application.routes.draw do

  scope '', controller: 'application', :format => false do
    get '/' => :reactapp
    get '/custom-transactions' => :reactapp
    get '/user/:id/ost-users' => :reactapp
    get '/user/:id/devices' => :reactapp
    get '/token' => :reactapp
    get '/health-checker' => :health_checker
  end

  scope 'api/setup/token', controller: 'api/setup/token', :format => false do
    get 'create' => :create, via: :POST
    get 'update' => :update, via: :POST
  end

  scope 'api/:url_id-:ost_token_id', :format => false do
    get 'signup' => :signup, controller: 'api/mobile/authenticate', via: :POST
    get 'login' => :login, controller: 'api/mobile/authenticate', via: :POST
  end

  # Route not found handler. Should be the last entry here
  match '*permalink', to: 'application#not_found', via: :all

end