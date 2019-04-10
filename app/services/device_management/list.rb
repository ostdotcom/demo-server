module DeviceManagement

  class List

    # List Device Constructor
    #
    def initialize(params)
      @token = params[:token]
      @token_user = params[:token_user]
      @pagination_identifier = params[:pagination_identifier]

      @token_id = @token[:id]

      @token_secure = nil
      @api_endpoint = nil
      @ost_devices_data = nil
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      r = fetch_token_secure
      return r unless r[:success]

      r = fetch_api_endpoint
      return r unless r[:success]

      r = fetch_device_from_ost
      return r unless r[:success]

      final_response
    end

    private

    # validate params
    #
    def validate_params
      r = validate_pagination_identifier
      return r unless r[:success]

      Result.success({})
    end

    # validate pagination identifier
    #
    def validate_pagination_identifier
      if @pagination_identifier.blank? || Validator.is_alphanumeric?(@pagination_identifier)
        Result.success({})
      else
        Result.error('a_s_dm_l_1', 'INVALID_REQUEST', 'Invalid pagination_identifier')
      end
    end

    # Fetch Token Secure data
    #
    def fetch_token_secure
      @token_secure = CacheManagement::TokenSecureById.new([@token_id]).fetch()[@token_id]
      return Result.error('a_s_dm_l_2',
                          'INVALID_REQUEST',
                          'Invalid token') if @token_secure.blank?
      Result.success({})
    end

    # Fetch API Endpoint
    #
    def fetch_api_endpoint
      @api_endpoint = ApiEndpoint.id_to_endpoint_map[@token[:api_endpoint_id]]
      return Result.error('a_s_dm_l_3',
                          'INVALID_REQUEST',
                          'Invalid token') if @api_endpoint.blank?
      Result.success({})
    end

    # Fetch devices list from OST
    #
    def fetch_device_from_ost

      ost_api_helper = OstApiHelper.new({api_key: @token_secure[:api_key],
                                         api_secret: @token_secure[:api_secret], api_endpoint: @api_endpoint})

      fetch_devices_params = {user_id: @token_user[:uuid]}
      if @pagination_identifier.present?
        fetch_devices_params[:pagination_identifier] = @pagination_identifier
      end

      response = ost_api_helper.fetch_devices(fetch_devices_params)
      unless response[:success]
        return Result.error('a_s_dm_l_4', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      @ost_devices_data = response[:data][response[:data][:result_type]]

      Result.success({})
    end

    # Final response
    #
    def final_response
      formatted_devices_data = []
      @ost_devices_data.each do |device_data|
        formatted_devices_data.push(ResponseEntity::Device.format(@token_user, device_data))
      end
      Result.success({
                         result_type: 'devices',
                         devices: formatted_devices_data
                     })
    end

  end

end