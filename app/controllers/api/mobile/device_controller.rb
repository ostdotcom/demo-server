class Api::Mobile::DeviceController < Api::BaseController

  # Register user device
  #
  def register
    response = DeviceManagement::Register.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

end
