class Api::TokenController < Api::BaseController

  # Get token detail
  #
  def get
    response = TokenManagement::Get.new(params).perform()
    return render_api_response(response)
  end

end
