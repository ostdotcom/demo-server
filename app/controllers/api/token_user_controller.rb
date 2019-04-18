class Api::TokenUserController < Api::BaseController

  # Get user detail by app_user_id
  #
  def get
    response = TokenUserManagement::GetByAppUserId.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

  # Get user detail of logged in user
  #
  def logged_in_user
    response = TokenUserManagement::GetLoggedInUser.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

  # Get users List
  #
  def list
    response = TokenUserManagement::List.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

  # Logout
  #
  def logout
    response = TokenUserManagement::Logout.new(params).perform()
    delete_cookie(GlobalConstant::Cookie.user_authentication_cookie) if response[:success]
    render plain: Oj.dump(response, mode: :compat) and return
  end

end
