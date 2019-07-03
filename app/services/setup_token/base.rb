module SetupToken

  class Base

    # Token Management Constructor
    #
    def initialize(params)
      @ost_token_id = params[:ost_token_id]
      @api_key = params[:api_key]
      @api_secret = params[:api_secret]
      @api_endpoint = params[:api_endpoint]
      @webhook_secret = params[:webhook_secret]

      @api_endpoint_id = nil
      @token_obj = nil
      @token_details_from_ost = nil
    end

    private

    # validate params
    #
    def validate_params
      r = validate_ost_token_id
      return r unless r[:success]

      r = validate_api_key
      return r unless r[:success]

      r = validate_api_secret
      return r unless r[:success]

      r = validate_api_endpoint
      return r unless r[:success]

      Result.success({})
    end

    # Validate ost token id
    #
    def validate_ost_token_id
      return Result.error('a_s_st_b_1', 'INVALID_REQUEST',
                          'Invalid OST token id') unless Validator.is_integer?(@ost_token_id)
      @ost_token_id = @ost_token_id.to_i
      Result.success({})
    end

    # Validate API key
    #
    def validate_api_key
      return Result.error('a_s_st_b_2', 'INVALID_REQUEST',
                         'Invalid api key') unless Validator.is_alphanumeric?(@api_key)

      Result.success({})
    end

    # Validate API secret
    #
    def validate_api_secret
      return Result.error('a_s_st_b_3', 'INVALID_REQUEST',
                          'Invalid api secret') unless Validator.is_alphanumeric?(@api_secret)

      Result.success({})
    end

    # Validate token name
    #
    def validate_token_name
      return Result.error('a_s_st_b_4', 'INVALID_REQUEST',
                          'Invalid token name') unless Validator.is_alphanumeric_space?(@name)
      Result.success({})
    end

    # Validate token name
    #
    def validate_token_symbol
      return Result.error('a_s_st_b_5', 'INVALID_REQUEST',
                         'Invalid token symbol') unless Validator.is_alphanumeric?(@symbol)
      Result.success({})
    end

    # Validate conversion factor
    #
    def validate_conversion_factor
      return Result.error('a_s_st_b_6', 'INVALID_REQUEST',
                          'Invalid conversion factor') unless Validator.is_numeric?(@conversion_factor)

      @conversion_factor = @conversion_factor.to_f

      Result.success({})
    end

    # Validate token url id
    #
    def validate_url_id
      return Result.error('a_s_st_b_7', 'INVALID_REQUEST',
                          'Invalid token url id') unless Validator.is_alphanumeric?(@url_id)
      Result.success({})
    end

    # Validate PC token holder uuid
    #
    def validate_token_holder_uuid
       return Result.error('a_s_st_b_8', 'INVALID_REQUEST',
                           'Invalid token holder uuid') unless Validator.is_uuid_v4?(@pc_token_holder_uuid)
       Result.success({})
    end

    # Validate chain id
    #
    def validate_chain_id
      return Result.error('a_s_st_b_9', 'INVALID_REQUEST',
                          'Invalid chain id') unless Validator.is_integer?(@chain_id)

      @chain_id = @chain_id.to_i

      Result.success({})
    end

    # Validate api endpoint
    #
    def validate_api_endpoint
      return Result.error('a_s_st_b_10', 'INVALID_REQUEST',
                          'Invalid api endpoint') unless Validator.is_url?(@api_endpoint)

      @api_endpoint_id = ApiEndpoint.endpoint_to_id_map[@api_endpoint]
      if @api_endpoint_id.blank?
        return Result.error('a_s_st_b_11', 'INVALID_REQUEST', 'Not registered api endpoint')
      end

      Result.success({})
    end

    # Fetch token details
    #
    def fetch_token_details

      ost_api_helper = OstApiHelper.new({api_key: @api_key,
                                         api_secret: @api_secret, api_endpoint: @api_endpoint})

      response = ost_api_helper.fetch_token_details
      unless response[:success]
        return Result.error('a_s_st_b_12', 'INVALID_REQUEST', 'Get token details from platform failed')
      end

      @token_details_from_ost = response[:data][response[:data][:result_type]]

      Result.success({})

    end

    # Validate if token details given in API Call match with data received from Platform
    #
    def validate_token_details

      if @token_details_from_ost[:id] != @ost_token_id || @token_details_from_ost[:name] != @name ||
        @token_details_from_ost[:symbol] != @symbol || @token_details_from_ost[:conversion_factor] != @conversion_factor ||
        @token_details_from_ost[:auxiliary_chains][0][:chain_id] != @chain_id
        return Result.error('a_s_st_b_13', 'INVALID_REQUEST',
                            'Token details from platform do not match with request params')
      end

      Result.success({})
    end

    # Final response
    #
    def final_response
      Result.success({result_type: 'token',
        token: ResponseEntity::Token.format(@token_obj.formated_cache_data, @token_details_from_ost)})
    end

  end

end