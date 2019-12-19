class Api::NotifyController < Api::BaseController

  # User activate notification.
  #
  def user_activate
    response = NotificationManagement::UserActivate.new(params).perform()
    return render_api_response(response)
  end

end
