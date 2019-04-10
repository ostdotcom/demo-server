module SetupToken

  class Create < SetupToken::Base

    # Create Token Constructor
    #
    def initialize(params)
      super(params)

      @name = params[:name]
      @symbol = params[:symbol]
      @conversion_factor = params[:conversion_factor]
      @chain_id = params[:chain_id]

      @url_id = params[:url_id]
      @pc_token_holder_uuid = params[:pc_token_holder_uuid]
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      r = create_token
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

      r = validate_conversion_factor
      return r unless r[:success]

      r = validate_url_id
      return r unless r[:success]

      r = validate_token_holder_uuid
      return r unless r[:success]

      r = validate_chain_id
      return r unless r[:success]

      r = fetch_token_details
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
        @token_obj = Token.new({
                                 ost_token_id: @ost_token_id,
                                 api_endpoint_id: @api_endpoint_id,
                                 name: @name,
                                 symbol: @symbol,
                                 conversion_factor: @conversion_factor,
                                 url_id: @url_id,
                                 api_key: @api_key,
                                 encryption_salt: generate_salt_rsp[:data][:ciphertext_blob],
                                 api_secret: api_secret_e,
                                 pc_token_holder_uuid: @pc_token_holder_uuid,
                                 chain_id: @chain_id
                               })
        @token_obj.save!
      rescue ActiveRecord::RecordNotUnique => e
        Rails.logger.error("create_token exception: #{e.message}")
        return Result.error('a_s_st_c_1', 'INVALID_REQUEST', 'Token already registered')
      rescue => e
        Rails.logger.error("create_token exception: #{e.message}")
        return Result.error('a_s_st_c_2', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
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