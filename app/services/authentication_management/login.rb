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

      final_response
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

  end

end