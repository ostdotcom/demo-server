class Api::EventController < Api::BaseController
  skip_before_action :authenticate_user
  skip_before_action :set_token_by_url_params

  # Ost event
  #
  def ost_event
    ost_raw_body = request.raw_post()
    response = OstEvents::Factory.new(request.headers.env, params, ost_raw_body).perform()
    Rails.logger.info "====response========#{response}"
    if !response[:success]
      Rails.logger.error("error in API Call: #{response}")
      response = Result.error("a_c_ec_1", "UNAUTHORISED", "Not allowed to access the endpoint")
      (render plain: Oj.dump(response, mode: :compat), status: '401') and return
    end
    render_api_response(response)
  end

end
