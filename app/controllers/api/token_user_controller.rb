class Api::TokenUserController < Api::BaseController

  # Logout.
  #
  def logout
    response = TokenUserManagement::Logout.new(params).perform()
    delete_cookie(GlobalConstant::Cookie.user_authentication_cookie) if response[:success]
    return render_api_response(response)
  end

  # Get users list.
  #
  def list
    response = TokenUserManagement::List.new(params).perform()
    return render_api_response(response)
  end

  # Get user detail of logged in user.
  #
  def logged_in_user_detail
    response = TokenUserManagement::ForLoggedInUser::GetDetail.new(params).perform()
    return render_api_response(response)
  end

  # Get salt detail of logged in user.
  #
  def logged_in_user_salts
    response = TokenUserManagement::ForLoggedInUser::GetSalt.new(params).perform()
    return render_api_response(response)
  end

  # Get transactions ledger of logged in user.
  #
  def logged_in_user_ledger
    response = TokenUserManagement::ForLoggedInUser::GetLedger.new(params).perform()
    return render_api_response(response)
  end

  # Get user detail by app_user_id.
  #
  def get_detail
    response = TokenUserManagement::ByAppUserId::GetDetail.new(params).perform()
    return render_api_response(response)
  end

  # Get user balance by app_user_id.
  #
  def get_balance
    response = TokenUserManagement::ByAppUserId::GetBalance.new(params).perform()
    return render_api_response(response)
  end

  # Set user crashlytics preference by app_user_id.
  #
  def set_crashlytics_preference
    response = TokenUserManagement::CrashlyticsPreference::Set.new(params).perform()
    return render_api_response(response)
  end

  # Get user crashlytics preference by app_user_id.
  #
  def get_crashlytics_preference
    response = TokenUserManagement::CrashlyticsPreference::Get.new(params).perform()
    return render_api_response(response)
  end

end
