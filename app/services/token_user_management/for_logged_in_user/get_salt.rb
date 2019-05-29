module TokenUserManagement

  module ForLoggedInUser

    class GetSalt

      # Get logged in user salts Constructor
      #
      def initialize(params)
        @token_user = params[:token_user]
        @user_salts = {}
      end

      # Perform action
      #
      def perform

        r = validate_params
        return r unless r[:success]

        r = fetch_and_decrypt_salt
        return r unless r[:success]

        final_response

      end

      private

      # validate params
      #
      def validate_params
        Result.success({})
      end

      # Fetch and decrypt salts
      #
      def fetch_and_decrypt_salt
        token_user_secure = CacheManagement::TokenUserSecure.new([@token_user[:id]]).fetch()[@token_user[:id]]
        if token_user_secure.blank?
          return Result.error('a_s_tum_gs_1', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
        end
        # lc_to_decrypt = LocalCipher.new(GlobalConstant::Base.local_cipher_key)
        # decrypt_user_pin_salt_res = lc_to_decrypt.decrypt(token_user_secure[:user_pin_salt])
        # return decrypt_user_pin_salt_res unless decrypt_user_pin_salt_res[:success]
        @user_salts = {
          # recovery_pin_salt: decrypt_user_pin_salt_res[:data][:plaintext],
          recovery_pin_salt: token_user_secure[:user_pin_salt],
          created_at: token_user_secure[:created_at],
          updated_at: token_user_secure[:updated_at]
        }
      end

      # final response
      #
      def final_response
        Result.success({
                           result_type: 'current_user_salt',
                           current_user_salt: ResponseEntity::CurrentTokenUserSalt.format(@token_user, @user_salts)
                       })
      end

    end

  end

end