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

  # Get User Details
  #
  def fetch_user_details(params)
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

  # Fetch Price Points
  #
  def fetch_price_points(params)
    response = price_points_service.get(params)
    handle_ost_response(response)
  end

  # Fetch rules data
  #
  def fetch_rules
    response = rules_service.get_list({})
    handle_ost_response(response)
  end

  # Initiate Company To User Transaction
  #
  def initiate_direct_transfer(params)
    transactions_service.execute(params)
  end

  # Fetch User Balance
  #
  def fetch_user_balance(params)
    response = balances_service.get(params)
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

  # Object to call Price Points Service related endpoints
  #
  def price_points_service
    @price_points_service ||= @sdk_obj.services.price_points
  end

  # Object to call Rules Service related endpoints
  #
  def rules_service
    @rules_service ||= @sdk_obj.services.rules
  end

  # Object to call Transactions Service related endpoints
  #
  def transactions_service
    @transactions_service ||= @sdk_obj.services.transactions
  end

  # Object to call Balance Service related endpoints
  #
  def balances_service
    @balances_service ||= @sdk_obj.services.balance
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