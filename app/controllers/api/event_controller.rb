class Api::EventController < Api::BaseController
  skip_before_action :authenticate_user
  skip_before_action :set_token_by_url_params

  # Ost event
  #
  def ost_event
    response = OstEvent::Factory.new(params, request.headers.env).perform()
    return render_api_response(response)
  end

end
