class Api::NotifyController < Api::BaseController

  # User activate notification
  #
  def user_activate
    response = NotificationManagement::UserActivate.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

end
