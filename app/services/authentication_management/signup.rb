module AuthenticationManagement

  class Signup < AuthenticationManagement::Base

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

      r = create_token_user
      return r unless r[:success]

      Result.success({cookie_value: cookie_value})
    end

    private

    # validate params
    #
    def validate_params
      r = super
      return r unless r[:success]

      r = validate_existing_user
      return r unless r[:success]

      Result.success({})
    end

    # Validate existing user
    #
    def validate_existing_user
      return Result.error('a_s_um_s_1',
                          'INVALID_REQUEST',
                          'Token user already exist, Please login.') if fetch_token_user.present?

      Result.success({})
    end

    # Create token user
    #
    def create_token_user
      generate_salt_rsp = Kms.new.generate_data_key
      return generate_salt_rsp unless generate_salt_rsp[:success]

      lc = LocalCipher.new(generate_salt_rsp[:data][:plaintext])
      encrypt_rsp = lc.encrypt(@password)
      return encrypt_rsp unless encrypt_rsp[:success]

      password_e = encrypt_rsp[:data][:ciphertext_blob]

      begin
        @token_user_obj = TokenUser.new({token_id: @token_id, username: @username, password: password_e,
                                    encryption_salt: generate_salt_rsp[:data][:ciphertext_blob],
                                    cookie_salt: SecureRandom.hex(35)})
        @token_user_obj.save!
      rescue StandardError => se
        Rails.logger.error("create_token_user exception: #{se.message}")
        return Result.error('a_s_um_s_2', 'INVALID_REQUEST', 'Token user signup failed')
      end

      Result.success({})
    end

  end

end