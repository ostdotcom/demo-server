Rails.application.routes.draw do

  scope '', controller: 'application', :format => false do
    get '/health-checker' => :health_checker
  end

  scope 'api/setup/token', controller: 'api/setup/token', :format => false do
    get 'create' => :create, via: :POST
    get 'update' => :update, via: :POST
  end


  # Route not found handler. Should be the last entry here
  match '*permalink', to: 'application#not_found', via: :all

end