module TokenUserManagement

  class GetByAppUserId

    # Get User Detail by app user id Constructor
    #
    def initialize(params)
      @token = params[:token]
      @app_user_id = params[:app_user_id]

      @token_user = nil
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      r = get_user_detail
      return r unless r[:success]

      final_response
    end

    private

    # validate params
    #
    def validate_params
      r = validate_token_user_id
      return r unless r[:success]

      Result.success({})
    end

    # validate token user id
    #
    def validate_token_user_id
      return Result.error('a_s_tum_g_1', 'INVALID_REQUEST', 'Invalid token user id') unless Validator.is_numeric?(@app_user_id)
      @app_user_id = @app_user_id.to_i
      Result.success({})
    end

    # Get user detail
    #
    def get_user_detail

      @token_user = CacheManagement::TokenUser.new([@app_user_id]).fetch()[@app_user_id]

      if @token_user.blank? || @token_user[:token_id] != @token[:id]
        return Result.error('a_s_tum_g_2', 'INVALID_REQUEST', 'Invalid token user id')
      end

      Result.success({})
    end

    # final response
    #
    def final_response
      Result.success({result_type: 'user', user: ResponseEntity::TokenUser.format(@token_user)})
    end

  end

end