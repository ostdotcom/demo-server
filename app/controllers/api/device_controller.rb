class Api::DeviceController < Api::BaseController

  # Register user device
  #
  def register
    response = DeviceManagement::Register.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

  # Get user device List
  #
  def list
    response = DeviceManagement::List.new(params).perform()
    render plain: Oj.dump(response, mode: :compat) and return
  end

end
