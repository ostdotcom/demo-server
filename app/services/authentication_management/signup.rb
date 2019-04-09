module AuthenticationManagement

  class Signup < AuthenticationManagement::Base

    # Login Constructor
    #
    def initialize(params)
      super(params)

      @fullname = params[:fullname]
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      r = create_token_user
      return r unless r[:success]

      final_response
    end

    private

    # validate params
    #
    def validate_params
      r = super
      return r unless r[:success]

      r = validate_fullname
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

      # Password
      encrypt_password_rsp = lc.encrypt(@password)
      return encrypt_rsp unless encrypt_password_rsp[:success]
      password_e = encrypt_password_rsp[:data][:ciphertext_blob]

      # User Pin Salt
      encrypt_user_pin_salt_rsp = lc.encrypt(BipMnemonic.to_mnemonic(bits: 256))
      return encrypt_rsp unless encrypt_user_pin_salt_rsp[:success]
      user_pin_salt_e = encrypt_user_pin_salt_rsp[:data][:ciphertext_blob]

      begin
        @token_user_obj = TokenUser.new({
                                          fullname: @fullname,
                                          username: @username,
                                          password: password_e,
                                          user_pin_salt: user_pin_salt_e,
                                          cookie_salt: SecureRandom.hex(35),
                                          encryption_salt: generate_salt_rsp[:data][:ciphertext_blob],
                                          token_id: @token_id,
                                          ost_token_id: @token.ost_token_id
                                        })
        @token_user_obj.save!
      rescue StandardError => se
        Rails.logger.error("create_token_user exception: #{se.message}")
        return Result.error('a_s_um_s_2', 'INVALID_REQUEST', 'Token user signup failed')
      end

      Result.success({})
    end

  end

end