module TokenManagement

  class Update < TokenManagement::Base

    # Update Token Constructor
    #
    def initialize(params)
      super(params)
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      update_token
      return r unless r[:success]

      final_response
    end

    private

    # validate params
    #
    def validate_params
      r = super
      return r unless r[:success]

      r = fetch_token_from_db
      return r unless r[:success]

      r = validate_token_details
      return r unless r[:success]

      Result.success({})
    end

    # fetch token from db
    #
    def fetch_token_from_db
      @token_obj = Token.where(ost_token_id: @ost_token_id, api_endpoint_id: @api_endpoint_id).first

      if @token_obj.blank?
        return Result.error('a_s_tm_u_1', 'INVALID_REQUEST',
                            'Token details not found')
      end
      Result.success({})
    end

    # Update Token
    #
    def update_token
      decrypt_salt_rsp = decrypt_salt
      return decrypt_salt_rsp unless decrypt_salt_rsp[:success]

      lc = LocalCipher.new(decrypt_salt_rsp[:data][:plaintext])
      encrypt_rsp = lc.encrypt(@api_secret)
      return encrypt_rsp unless encrypt_rsp[:success]

      api_secret_e = encrypt_rsp[:data][:ciphertext_blob]

      begin
        @token_obj.api_key = @api_key
        @token_obj.api_secret = api_secret_e
        @token_obj.save!
      rescue StandardError => se
        Rails.logger.error("update_token exception: #{se.message}")
        return Result.error('a_s_tm_u_1', 'INVALID_REQUEST', 'Token update failed')
      end

      Result.success({})
    end

    # Decrypt salt
    #
    def decrypt_salt
      Kms.new.decrypt(@token_obj.encryption_salt)
    end


  end

end