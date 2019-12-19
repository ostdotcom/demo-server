class Api::DeviceController < Api::BaseController

  # Register user device.
  #
  def register
    response = DeviceManagement::Register.new(params).perform()
    return render_api_response(response)
  end

  # Get user device list.
  #
  def list
    response = DeviceManagement::List.new(params).perform()
    return render_api_response(response)
  end

end
