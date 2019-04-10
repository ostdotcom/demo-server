module DeviceManagement

  class Register

    # Register Device Constructor
    #
    def initialize(params)
      @token = params[:token]
      @token_id = @token[:id]
      @token_user = params[:token_user]

      @uuid = params[:uuid]
      @address = params[:address]
      @api_signer_address = params[:api_signer_address]

      @token_secure = nil
      @api_endpoint = nil
      @ost_device_data = nil
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

      r = register_device_in_ost
      return r unless r[:success]

      final_response
    end

    private

    # validate params
    #
    def validate_params
      r = validate_uuid
      return r unless r[:success]

      r = validate_address
      return r unless r[:success]

      r = validate_api_signer_address
      return r unless r[:success]

      Result.success({})
    end

    # Validate uuid
    #
    def validate_uuid
      return Result.error('a_s_dm_r_1', 'INVALID_REQUEST',
                          'Invalid uuid') if @token_user[:uuid] != @uuid || !Validator.is_uuid_v4?(@uuid)
      Result.success({})
    end

    # Validate address
    #
    def validate_address
      return Result.error('a_s_dm_r_2', 'INVALID_REQUEST',
                          'Invalid address') unless Validator.is_ethereum_address?(@address)
      Result.success({})
    end

    # Validate api signer address
    #
    def validate_api_signer_address
      return Result.error('a_s_dm_r_3', 'INVALID_REQUEST',
                          'Invalid api signer address') unless Validator.is_ethereum_address?(@api_signer_address)
      Result.success({})
    end

    # Fetch Token Secure data
    #
    def fetch_token_secure
      @token_secure = CacheManagement::TokenSecureById.new([@token_id]).fetch()[@token_id]
      return Result.error('a_s_dm_r_4',
                          'INVALID_REQUEST',
                          'Invalid token') if @token_secure.blank?
      Result.success({})
    end

    # Fetch API Endpoint
    #
    def fetch_api_endpoint
      @api_endpoint = ApiEndpoint.id_to_endpoint_map[@token[:api_endpoint_id]]
      return Result.error('a_s_dm_r_5',
                          'INVALID_REQUEST',
                          'Invalid token') if @api_endpoint.blank?
      Result.success({})
    end

    # Register device in OST
    #
    def register_device_in_ost

      ost_api_helper = OstApiHelper.new({api_key: @token_secure[:api_key],
                                         api_secret: @token_secure[:api_secret], api_endpoint: @api_endpoint})

      response = ost_api_helper.register_device({user_id: @uuid, address: @address, api_signer_address: @api_signer_address})
      unless response[:success]
        return Result.error('a_s_dm_r_6', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      @ost_device_data = response[:data][response[:data][:result_type]]

      Result.success({})
    end

    # Final response
    #
    def final_response
      Result.success({
                       result_type: 'device',
                       device: ResponseEntity::Device.format(@token_user, @ost_device_data)
                     })
    end

  end

end