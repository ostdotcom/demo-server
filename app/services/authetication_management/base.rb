module AuthenticationManagement

  class Base

    # Authentication Management Constructor
    #
    def initialize(params)
      @token = params[:token]
      @username = params[:username]
      @password = params[:password]
      @token_id = @token[:id]

      @token_user_obj = nil
      @api_endpoint = nil

      @token_user_secure = nil
    end

    private

    # validate params
    #
    def validate_params
      r = validate_username
      return r unless r[:success]

      r = validate_password
      return r unless r[:success]

      Result.success({})
    end

    # Validate Username
    #
    def validate_username
      return Result.error('a_s_am_b_3', 'INVALID_REQUEST',
                          'Invalid username') unless Validator.is_alphanumeric?(@username)

      Result.success({})
    end

    # Validate Password
    #
    def validate_password
      return Result.error('a_s_tm_b_4', 'INVALID_REQUEST',
                          'Invalid password') unless @password.present?

      Result.success({})
    end

    # Fetch token user
    #
    def fetch_token_user
      @token_user_obj ||= TokenUser.where(token_id: @token_id, username: @username).first
    end

    # Get api endpoint
    #
    def api_endpoint
      @api_endpoint ||= ApiEndpoint.id_to_endpoint_map[@token.api_endpoint_id]
    end

    # Get cookie value
    #
    def cookie_value
      @token_user_secure ||= CacheManagement::TokenUserSecure.new([@token_user_obj[:id]]).fetch()
      TokenUser.get_cookie_value(@token_user_secure)
    end

  end

end