class Api::TokenController < Api::BaseController

  # Get token detail
  #
  def get
    response = TokenManagement::Get.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

end
