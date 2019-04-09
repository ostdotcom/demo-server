module TokenManagement

  class Create < TokenManagement::Base

    # Create Token Constructor
    #
    def initialize(params)
      super(params)

      @name = params[:name]
      @symbol = params[:symbol]

      @url_id = params[:url_id]
      @pc_token_holder_uuid = params[:pc_token_holder_uuid]
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      create_token
      return r unless r[:success]

      final_response
    end

    private

    # validate params
    #
    def validate_params
      r = super
      return r unless r[:success]

      r = validate_token_name
      return r unless r[:success]

      r = validate_token_symbol
      return r unless r[:success]

      r = validate_url_id
      return r unless r[:success]

      r = validate_token_holder_uuid
      return r unless r[:success]

      r = validate_token_details
      return r unless r[:success]

      Result.success({})
    end


    # Create Token
    #
    def create_token
      generate_salt_rsp = generate_salt
      return generate_salt_rsp unless generate_salt_rsp[:success]

      lc = LocalCipher.new(generate_salt_rsp[:data][:plaintext])
      encrypt_rsp = lc.encrypt(@api_secret)
      return encrypt_rsp unless encrypt_rsp[:success]

      api_secret_e = encrypt_rsp[:data][:ciphertext_blob]

      begin
        @token_obj = Token.new({ost_token_id: @ost_token_id, api_endpoint_id: @api_endpoint_id, name: @name, symbol: @symbol,
                           url_id: @url_id, api_key: @api_key, encryption_salt: generate_salt_rsp[:data][:ciphertext_blob],
                           api_secret: api_secret_e, pc_token_holder_uuid: @pc_token_holder_uuid})
        @token_obj.save!
      rescue StandardError => se
        Rails.logger.error("create_token exception: #{se.message}")
        return Result.error('a_s_tm_c_1', 'INVALID_REQUEST', 'Token already registered')
      end

      Result.success({})
    end

    # Generate salt
    #
    def generate_salt
      Kms.new.generate_data_key
    end

  end

end