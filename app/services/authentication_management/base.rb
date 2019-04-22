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

      @token_user = nil
      @token_user_secure = nil
    end

    private

    # validate params
    #
    def validate_params
      param_validation_errors = []
      if @username.blank? || @username.length > 25 || !Validator.is_alphanumeric?(@username)
        param_validation_errors.push({
                                         parameter: 'username',
                                         msg: 'Invalid username'
                                     })
      end
      if @password.blank? || @password.length > 25 || !Validator.is_alphanumeric?(@password)
        param_validation_errors.push({
                                         parameter: 'password',
                                         msg: 'Invalid password'
                                     })
      end
      param_validation_errors.any? ? Result.param_validation_error('a_s_am_b_1', param_validation_errors) :
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

    # Final response
    #
    def final_response
      @token_user_secure ||= CacheManagement::TokenUserSecure.new([@token_user_obj[:id]]).fetch()[@token_user_obj[:id]]
      @token_user ||= CacheManagement::TokenUser.new([@token_user_obj[:id]]).fetch()[@token_user_obj[:id]]
      Result.success({
                       result_type: 'current_user',
                       current_user: ResponseEntity::CurrentTokenUser.format(@token_user, @token_user_secure),
                       cookie_value: TokenUser.get_cookie_value(@token_user_secure)
                     })
    end

  end

end