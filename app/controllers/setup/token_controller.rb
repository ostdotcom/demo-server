class Setup::TokenController < ApplicationController

  # Create token
  #
  def create
    response = SetupToken::Create.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

  # Update token
  #
  def update
    response = SetupToken::Update.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

end
