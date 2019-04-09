class Api::Mobile::AuthenticationController < Api::Mobile::BaseController
  skip_before_action :authenticate_user

  # Signup
  #
  def signup
    response = AuthenticationManagement::Signup.new(params).perform()
    if response[:success]
      set_cookie(GlobalConstant::Cookie.user_authentication_cookie, response[:data][:cookie_value], 1.year)
      response = Result.success({})
    else
      delete_cookie(GlobalConstant::Cookie.user_authentication_cookie)
    end
    render plain: Oj.dump(response, mode: :compat) and return
  end

  # Login
  #
  def login
    response = AuthenticationManagement::Login.new(params).perform()
    if response[:success]
      set_cookie(GlobalConstant::Cookie.user_authentication_cookie, response[:data][:cookie_value], 1.year)
      response = Result.success({})
    else
      delete_cookie(GlobalConstant::Cookie.user_authentication_cookie)
    end
    render plain: Oj.dump(response, mode: :compat) and return
  end

end
