class Setup::TokenController < ApplicationController

  # Create token
  #
  def create
    response = SetupToken::Create.new(params).perform()
    return render_api_response(response)
  end

  # Update token
  #
  def update
    response = SetupToken::Update.new(params).perform()
    return render_api_response(response)
  end

  # Get token users stats
  #
  def get_token_stats
    response = TokenManagement::GetStats.new(params).perform
    return render_api_response(response)
  end

end
