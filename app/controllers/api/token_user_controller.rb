class Api::TokenUserController < Api::BaseController

  # Get user detail
  #
  def get
    response = TokenUserManagement::Get.new(params).perform()
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
