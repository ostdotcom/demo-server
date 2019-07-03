class Setup::TokenController < ApplicationController

  before_action :decrypt_jwt

  # Create token
  #
  def create
    response = SetupToken::Create.new(params[:decoded_token_data]).perform()
    return render_api_response(response)
  end

  # Update token
  #
  def update
    response = SetupToken::Update.new(params[:decoded_token_data]).perform()
    return render_api_response(response)
  end

  # Get token users stats
  #
  def get_token_stats
    response = TokenManagement::GetStats.new(params[:decoded_token_data]).perform
    return render_api_response(response)
  end

end
