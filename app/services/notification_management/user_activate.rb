module NotificationManagement

  class UserActivate

    # User Activate Constructor
    #
    def initialize(params)
      @token = params[:token]
      @token_id = @token[:id]
      @token_user = params[:token_user]
      @uuid = params[:uuid]

      @token_secure = nil
      @api_endpoint = nil
      @ost_user_data = nil
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

      r = fetch_user_from_ost
      return r unless r[:success]

      r = update_token_user
      return r unless r[:success]

      final_response
    end

    private

    # validate params
    #
    def validate_params
      r = validate_uuid
      return r unless r[:success]

      r = validate_user_status
      return r unless r[:success]

      Result.success({})
    end

    # Validate uuid
    #
    def validate_uuid
      return Result.error('a_s_nm_ua_1', 'INVALID_REQUEST',
                          'Invalid uuid') if @token_user[:uuid] != @uuid || !Validator.is_uuid_v4?(@uuid)
      Result.success({})
    end

    # Validate user status
    #
    def validate_user_status
      return Result.error('a_s_nm_ua_2', 'INVALID_REQUEST',
                          'User already activated') if @token_user[:status] != 'CREATED'
      Result.success({})
    end

    # Fetch Token Secure data
    #
    def fetch_token_secure
      @token_secure = CacheManagement::TokenSecureById.new([@token_id]).fetch()[@token_id]
      return Result.error('a_s_nm_ua_2',
                          'INVALID_REQUEST',
                          'Invalid token') if @token_secure.blank?
      Result.success({})
    end

    # Fetch API Endpoint
    #
    def fetch_api_endpoint
      @api_endpoint = ApiEndpoint.id_to_endpoint_map[@token[:api_endpoint_id]]
      return Result.error('a_s_um_s_3',
                          'INVALID_REQUEST',
                          'Invalid token') if @api_endpoint.blank?
      Result.success({})
    end

    # Fetch users from OST
    #
    def fetch_user_from_ost

      ost_api_helper = OstApiHelper.new({api_key: @token_secure[:api_key],
                                         api_secret: @token_secure[:api_secret], api_endpoint: @api_endpoint})

      response = ost_api_helper.get_user({user_id: @uuid})
      unless response[:success]
        return Result.error('a_s_um_s_4', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      @ost_user_data = response[:data][response[:data][:result_type]]

      Result.success({})
    end

    # Update token user
    #
    def update_token_user
      begin
        token_user_obj = ::TokenUser.where(id: @token_user[:id]).first
        token_user_obj.token_holder_address = @ost_user_data[:token_holder_address]
        token_user_obj.device_manager_address = @ost_user_data[:token_holder_address]
        token_user_obj.recovery_address = @ost_user_data[:recovery_address]
        token_user_obj.ost_user_status = @ost_user_data[:status]
        token_user_obj.save!
      rescue => e
        Rails.logger.error("update_token_user exception: #{e.message}")
        return Result.error('a_s_um_s_5', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      Result.success({})
    end

    # Final response
    #
    def final_response
      updated_token_user_secure = CacheManagement::TokenUserSecure.new([@token_user[:id]]).fetch()[@token_user[:id]]
      updated_token_user = CacheManagement::TokenUser.new([@token_user[:id]]).fetch()[@token_user[:id]]
      Result.success({
                       result_type: 'current_user',
                       current_user: ResponseEntity::CurrentTokenUser.format(updated_token_user, updated_token_user_secure)
                     })
    end

  end

end