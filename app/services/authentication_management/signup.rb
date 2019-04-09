module AuthenticationManagement

  class Signup < AuthenticationManagement::Base

    # Login Constructor
    #
    def initialize(params)
      super(params)

      @fullname = params[:fullname]

      @token_secure = nil
      @api_endpoint = nil
      @uuid = nil
      @ost_user_status = nil
    end

    # Perform action
    #
    def perform

      r = validate_params
      return r unless r[:success]

      r = fetch_token_secure
      return r unless r[:success]

      r = fetch_api_endpoint
      return r unless r[:success]

      r = create_token_user_in_ost
      return r unless r[:success]

      r = create_token_user_in_db
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

    # Fetch Token Secure data
    #
    def fetch_token_secure
      @token_secure = CacheManagement::TokenSecureById.new([@token_id]).fetch()[@token_id]
      return Result.error('a_s_um_s_2',
                          'INVALID_REQUEST',
                          'Invalid URL Identifier') if @token_secure.blank?
      Result.success({})
    end

    # Fetch API Endpoint
    #
    def fetch_api_endpoint
      @api_endpoint = ApiEndpoint.id_to_endpoint_map[@token[:api_endpoint_id]]
      return Result.error('a_s_um_s_3',
                          'INVALID_REQUEST',
                          'Invalid URL Identifier') if @api_endpoint.blank?
      Result.success({})
    end

    # Create token user in OST
    #
    def create_token_user_in_ost

      ost_api_helper = OstApiHelper.new({api_key: @token_secure[:api_key],
                                         api_secret: @token_secure[:api_secret], api_endpoint: @api_endpoint})

      response = ost_api_helper.create_user
      unless response[:success]
        return Result.error('a_s_um_s_4', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      ost_user_data = response[:data][response[:data][:result_type]]
      @uuid = ost_user_data[:id]
      @ost_user_status = ost_user_data[:status]

      Result.success({})
    end

    # Create token user in DB
    #
    def create_token_user_in_db
      generate_salt_rsp = Kms.new.generate_data_key
      return generate_salt_rsp unless generate_salt_rsp[:success]
      lc = LocalCipher.new(generate_salt_rsp[:data][:plaintext])

      # Password
      encrypt_password_rsp = lc.encrypt(@password)
      return encrypt_rsp unless encrypt_password_rsp[:success]
      password_e = encrypt_password_rsp[:data][:ciphertext_blob]

      # User Pin Salt
      encrypt_user_pin_salt_rsp = lc.encrypt(SecureRandom.hex(100))
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
                                          ost_token_id: @token[:ost_token_id],
                                          uuid: @uuid,
                                          ost_user_status: @ost_user_status
                                        })
        @token_user_obj.save!
      rescue ActiveRecord::RecordNotUnique => e
        Rails.logger.error("create_token_user exception: #{e.message}")
        return Result.error('a_s_um_s_2', 'INVALID_REQUEST', 'Token user signup failed')
      rescue => e
        Rails.logger.error("create_token_user exception: #{e.message}")
        return Result.error('a_s_um_s_3', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      Result.success({})
    end

  end

end