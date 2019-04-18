module TokenUserManagement

  class GetLoggedInUser

    # Get logged in user detail Constructor
    #
    def initialize(params)
      @token = params[:token]
      @token_user = params[:token_user]
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      final_response
    end

    private

    # validate params
    #
    def validate_params
      Result.success({})
    end

    # final response
    #
    def final_response
      token_user_secure = CacheManagement::TokenUserSecure.new([@token_user[:id]]).fetch()[@token_user[:id]]
      Result.success({
                         result_type: 'current_user',
                         current_user: ResponseEntity::CurrentTokenUser.format(@token_user, token_user_secure)
                     })
    end

  end

end