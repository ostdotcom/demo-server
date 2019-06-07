class Api::TokenUserController < Api::BaseController

  # Logout
  #
  def logout
    response = TokenUserManagement::Logout.new(params).perform()
    delete_cookie(GlobalConstant::Cookie.user_authentication_cookie) if response[:success]
    return render_api_response(response)
  end

  # Get users List
  #
  def list
    response = TokenUserManagement::List.new(params).perform()
    return render_api_response(response)
  end

  # Get user detail of logged in user
  #
  def logged_in_user_detail
    response = TokenUserManagement::ForLoggedInUser::GetDetail.new(params).perform()
    return render_api_response(response)
  end

  # Get user detail of logged in user salts
  #
  def logged_in_user_salts
    response = TokenUserManagement::ForLoggedInUser::GetSalt.new(params).perform()
    return render_api_response(response)
  end

  # Get user transactions ledger of logged in user
  #
  def logged_in_user_ledger
    response = TokenUserManagement::ForLoggedInUser::GetLedger.new(params).perform()
    return render_api_response(response)
  end

  # Get user detail by app_user_id
  #
  def get_detail
    response = TokenUserManagement::ByAppUserId::GetDetail.new(params).perform()
    return render_api_response(response)
  end

  # Get user balance by app_user_id
  #
  def get_balance
    response = TokenUserManagement::ByAppUserId::GetBalance.new(params).perform()
    return render_api_response(response)
  end

end
