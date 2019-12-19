class Api::EventController < Api::BaseController
  skip_before_action :authenticate_user
  skip_before_action :set_token_by_url_params

  # Ost event
  #
  def ost_event
    response = OstEvents::Factory.new(request.headers.env, params, request.raw_post()).perform()
    if !response[:success]
      Rails.logger.error("error in API Call: #{response}")
      response = Result.error("a_c_ec_1", "UNAUTHORISED", "Not allowed to access the endpoint")
      (render plain: Oj.dump(response, mode: :compat), status: '401') and return
    end
    render_api_response(response)
  end

end
