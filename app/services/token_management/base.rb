module TokenManagement

  class Base

    # Token Management Constructor
    #
    def initialize(params)
      @ost_token_id = params[:ost_token_id]
      @api_key = params[:api_key]
      @api_secret = params[:api_secret]
      @api_endpoint = params[:api_endpoint]
      @api_endpoint_id = nil
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
      return Result.error('a_s_tm_b_1', 'INVALID_REQUEST',
                          'Invalid OST token id') unless Validator.is_integer?(@ost_token_id)
      @ost_token_id = @ost_token_id.to_i
      Result.success({})
    end

    # Validate API key
    #
    def validate_api_key
      return Result.error('a_s_tm_b_2', 'INVALID_REQUEST',
                         'Invalid api key') unless Validator.is_alphanumeric?(@api_key)

      Result.success({})
    end

    # Validate API secret
    #
    def validate_api_secret
      return Result.error('a_s_tm_b_3', 'INVALID_REQUEST',
                          'Invalid api secret') unless Validator.is_alphanumeric?(@api_secret)

      Result.success({})
    end

    # Validate token name
    #
    def validate_token_name
      return Result.error('a_s_tm_b_4', 'INVALID_REQUEST',
                          'Invalid token name') unless Validator.is_alphanumeric_space?(@name)
      Result.success({})
    end

    # Validate token name
    #
    def validate_token_symbol
      return Result.error('a_s_tm_b_5', 'INVALID_REQUEST',
                         'Invalid token symbol') unless Validator.is_alphanumeric?(@symbol)
      Result.success({})
    end

    # Validate token url id
    #
    def validate_url_id
      return Result.error('a_s_tm_b_6', 'INVALID_REQUEST',
                          'Invalid token url id') unless Validator.is_alphanumeric?(@url_id)
      Result.success({})
    end

    # Validate PC token holder uuid
    #
    def validate_token_holder_uuid
       return Result.error('a_s_tm_b_7', 'INVALID_REQUEST',
                           'Invalid token holder uuid') unless Validator.is_uuid_v4?(@pc_token_holder_uuid)
       Result.success({})
    end

    # Validate api endpoint
    #
    def validate_api_endpoint
      return Result.error('a_s_tm_b_8', 'INVALID_REQUEST',
                          'Invalid api endpoint') unless Validator.is_url?(@api_endpoint)

      @api_endpoint_id = ApiEndpoint.endpoint_to_id_map[@api_endpoint]
      if @api_endpoint_id.blank?
        return Result.error('a_s_tm_b_9', 'INVALID_REQUEST', 'Not registered api endpoint')
      end

      Result.success({})
    end

    # Fetch token details
    #
    def fetch_token_details
      sdk_obj = OSTSdk::Saas::Services.new({api_key: @api_key, api_secret: @api_secret, api_base_url: @api_endpoint})
      tokens_service = sdk_obj.services.tokens

      response = tokens_service.get({})
      unless response['success']
        return Result.error('a_s_tm_b_10', 'INVALID_REQUEST', 'Get token details from platform failed')
      end

      Result.success(response['data'])
    end

    # Validate if token details given in API Call match with data received from Platform
    #
    def validate_token_details
      r = fetch_token_details
      return r unless r[:success]

      token_details_from_ost = r[:data]

      token_details = token_details_from_ost[token_details_from_ost['result_type']]
      if token_details['id'] != @ost_token_id || token_details['name'] != @name || token_details['symbol'] != @symbol
        return Result.error('a_s_tm_b_11', 'INVALID_REQUEST',
                            'Token details from platform do not match with request params')
      end

      Result.success({})
    end

  end

end