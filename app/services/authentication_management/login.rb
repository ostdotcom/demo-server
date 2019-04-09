module AuthenticationManagement

  class Login < AuthenticationManagement::Base

    # Login Constructor
    #
    def initialize(params)
      super(params)
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      r = update_token_user
      return r unless r[:success]

      Result.success({cookie_value: cookie_value})
    end

    private

    # validate params
    #
    def validate_params
      r = super
      return r unless r[:success]

      r = verify_login_details
      return r unless r[:success]

      Result.success({})
    end

    # Verify login details
    #
    def verify_login_details
      return Result.error('a_s_um_l_1',
                          'INVALID_REQUEST',
                          'Token user not found or password incorrect') if fetch_token_user.blank?

      existing_token_user_secure = CacheManagement::TokenUserSecure.new([@token_user_obj[:id]]).fetch()[@token_user_obj[:id]]
      return Result.error('a_s_um_l_2',
                          'INVALID_REQUEST',
                          'Token user not found or password incorrect') if existing_token_user_secure[:password] != @password

      Result.success({})
    end

    # Update token user
    #
    def update_token_user
      begin
        @token_user_obj.cookie_salt = SecureRandom.hex(35)
        @token_user_obj.save!
      rescue StandardError => se
        Rails.logger.error("update_token_user exception: #{se.message}")
        return Result.error('a_s_um_l_3', 'INVALID_REQUEST', 'Something went wrong')
      end

      Result.success({})
    end

  end

end