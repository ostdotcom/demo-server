class OstApiHelper

  # Initialize
  #
  def initialize(params)
    @sdk_obj = OSTSdk::Saas::Services.new({api_key: params[:api_key],
                                           api_secret: params[:api_secret], api_base_url: params[:api_endpoint]})
  end

  # Fetch Token Details
  #
  def fetch_token_details
    response = tokens_service.get({})
    handle_ost_response(response)
  end

  # Create User
  #
  def create_user
    response = users_service.create({})
    handle_ost_response(response)
  end

  # Get User
  #
  def get_user(params)
    response = users_service.get(params)
    handle_ost_response(response)
  end

  # Register Device
  #
  def register_device(params)
    response = devices_service.create(params)
    handle_ost_response(response)
  end

  # Fetch Device list
  #
  def fetch_devices(params)
    response = devices_service.get_list(params)
    handle_ost_response(response)
  end

  private

  # Object to call Tokens Service related endpoints
  #
  def tokens_service
    @tokens_service ||= @sdk_obj.services.tokens
  end

  # Object to call Users Service related endpoints
  #
  def users_service
    @users_service ||= @sdk_obj.services.users
  end

  # Object to call Devices Service related endpoints
  #
  def devices_service
    @devices_service ||= @sdk_obj.services.devices
  end

  # handle OST response
  #
  def handle_ost_response(response)
    unless response['success']
      return Result.error('l_oah_1', 'INTERNAL_SERVER_ERROR', 'Request to OST failed')
    end
    Result.success(HashWithIndifferentAccess.new(response['data']))
  end

end