module TokenManagement

  class Get

    # Get Token Constructor
    #
    def initialize(params)
      @token = params[:token]
      @token_id = @token[:id]
      @chain_id = @token[:chain_id]

      @token_secure = nil
      @api_endpoint = nil
      @ost_api_helper = nil
      @ost_price_point_data = nil
      @ost_token_details = nil
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

      r = set_ost_api_helper
      return r unless r[:success]

      r = fetch_price_points_from_ost
      return r unless r[:success]

      r = fetch_token_details_from_ost
      return r unless r[:success]

      final_response

    end

    private

    # validate params
    #
    def validate_params
      Result.success({})
    end

    # Fetch Token Secure data
    #
    def fetch_token_secure
      @token_secure = CacheManagement::TokenSecureById.new([@token_id]).fetch()[@token_id]
      return Result.error('a_s_tm_g_1',
                          'INVALID_REQUEST',
                          'Invalid token') if @token_secure.blank?
      Result.success({})
    end

    # Fetch API Endpoint
    #
    def fetch_api_endpoint
      @api_endpoint = ApiEndpoint.id_to_endpoint_map[@token[:api_endpoint_id]]
      return Result.error('a_s_tm_g_2',
                          'INVALID_REQUEST',
                          'Invalid token') if @api_endpoint.blank?
      Result.success({})
    end

    # Set OST API Helper Object
    #
    def set_ost_api_helper
      @ost_api_helper = OstApiHelper.new({api_key: @token_secure[:api_key],
                                          api_secret: @token_secure[:api_secret], api_endpoint: @api_endpoint})
      Result.success({})
    end

    # Fetch price points from OST
    #
    def fetch_price_points_from_ost
      response = @ost_api_helper.fetch_price_points({chain_id: @chain_id})
      unless response[:success]
        return Result.error('a_s_tm_g_3', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end
      @ost_price_point_data = response[:data][response[:data][:result_type]]
      Result.success({})
    end

    # Fetch token details from OST
    #
    def fetch_token_details_from_ost
      response = @ost_api_helper.fetch_token_details
      unless response[:success]
        return Result.error('a_s_tm_g_4', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end
      @ost_token_details = response[:data][response[:data][:result_type]]
      Result.success({})
    end

    # Final response
    #
    def final_response
      Result.success({
                       result_type: 'token',
                       token: ResponseEntity::Token.format(@token, @ost_token_details),
                       price_point: @ost_price_point_data
                     })
    end

  end

end