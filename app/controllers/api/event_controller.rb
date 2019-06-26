class Api::EventController < Api::BaseController

  # Ost event
  #
  def ost_event
    response = OstEvent::Factory.new(params).perform()
    return render_api_response(response)
  end

end
