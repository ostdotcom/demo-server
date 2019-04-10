module TokenUserManagement

  class Logout

    # Logout Constructor
    #
    def initialize(params)
      @token = params[:token]
      @token_id = @token[:id]
      @token_user = params[:token_user]
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      r = update_token_user
      return r unless r[:success]

      final_response
    end

    private

    # validate params
    #
    def validate_params
      Result.success({})
    end

    # Update token user
    #
    def update_token_user
      begin
        token_user_obj = ::TokenUser.where(id: @token_user[:id]).first
        token_user_obj.cookie_salt = SecureRandom.hex(35)
        token_user_obj.save!
      rescue => e
        Rails.logger.error("update_token_user exception: #{e.message}")
        return Result.error('a_s_tum_l_1', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      Result.success({})
    end

    # Final response
    #
    def final_response
      Result.success({})
    end

  end

end