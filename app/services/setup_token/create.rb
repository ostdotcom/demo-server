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

      r = subscribe_webhooks
      unless r[:success]
        Rails.logger.info "Exception in Creating Webhook for economy ost_token_id: #{@ost_token_id}"
        ApplicationMailer.notify(
          data: r,
          body: {name: @name, symbol: @symbol, chain_id: @chain_id, ost_token_id: @ost_token_id },
          subject: 'Exception in Creating Webhook for economy.'
        ).deliver
      end

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

    def subscribe_webhooks
      r = set_ost_api_helper
      return r unless r[:success]

      @ost_api_helper.create_webhooks({
                                        topics: GlobalConstant::OstEvents.webhook_topics,
                                        url: GlobalConstant::OstEvents.webhook_subscription_endpoint})
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
      webhook_secret_e = nil
      if @webhook_secret.present?
        encrypt_resp = lc.encrypt(@webhook_secret)
        webhook_secret_e = encrypt_resp[:data][:ciphertext_blob] rescue nil
      end

      begin
        @token_obj = Token.new({
                                 ost_token_id: @ost_token_id,
                                 api_endpoint_id: @api_endpoint_id,
                                 name: @name,
                                 symbol: @symbol,
                                 decimal: @token_details_from_ost[:decimals],
                                 conversion_factor: @conversion_factor,
                                 url_id: @url_id,
                                 api_key: @api_key,
                                 encryption_salt: generate_salt_rsp[:data][:ciphertext_blob],
                                 api_secret: api_secret_e,
                                 webhook_secret: webhook_secret_e,
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

    # Set OST API Helper Object
    #
    def set_ost_api_helper
      @ost_api_helper = OstApiHelper.new({api_key: @api_key,
                                          api_secret: @api_secret, api_endpoint: @api_endpoint})
      Result.success({})
    end

  end

end
