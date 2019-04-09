class Setup::TokenController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Create token
  #
  def create
    response = TokenManagement::Create.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

  # Update token
  #
  def update
    response = TokenManagement::Update.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

end
