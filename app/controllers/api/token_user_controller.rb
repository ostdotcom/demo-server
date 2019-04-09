class Api::TokenUserController < Api::BaseController
  skip_before_action :authenticate_user

  # List
  #
  def list
    response = TokenUserManagement::List.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

end
