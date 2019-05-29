module NotificationManagement

  class UserActivate

    # User Activate Constructor
    #
    def initialize(params)
      @token = params[:token]
      @token_id = @token[:id]
      @token_user = params[:token_user]

      @token_secure = nil
      @api_endpoint = nil
      @user_data_from_ost = nil
      @rule_address_from_ost = nil
      @bt_grant_amount_in_wei = nil
      @ost_api_helper = nil
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

      r = set_ost_api_helper
      return r unless r[:success]

      r = fetch_user_from_ost
      return r unless r[:success]

      r = check_eligibility_and_grant_bt
      unless r[:success]
        # as grant is not a blocker to activate user. proceed to user activation even if it fails
        Rails.logger.info("check_eligibility_and_grant_bt error: #{r}")
      end

      r = update_token_user
      return r unless r[:success]

      final_response

    end

    private

    # validate params
    #
    def validate_params

      r = validate_user_status
      return r unless r[:success]

      Result.success({})
    end


    # Validate user status
    #
    def validate_user_status
      return Result.error('a_s_nm_ua_2', 'INVALID_REQUEST',
                          'User already activated') if @token_user[:ost_user_status] != 'CREATED'
      Result.success({})
    end

    # Fetch Token Secure data
    #
    def fetch_token_secure
      @token_secure = CacheManagement::TokenSecureById.new([@token_id]).fetch()[@token_id]
      return Result.error('a_s_nm_ua_3',
                          'INVALID_REQUEST',
                          'Invalid token') if @token_secure.blank?
      Result.success({})
    end

    # Fetch API Endpoint
    #
    def fetch_api_endpoint
      @api_endpoint = ApiEndpoint.id_to_endpoint_map[@token[:api_endpoint_id]]
      return Result.error('a_s_nm_ua_4',
                          'INVALID_REQUEST',
                          'Invalid token') if @api_endpoint.blank?
      Result.success({})
    end

    # Set OST API Helper Object
    #
    def set_ost_api_helper
      @ost_api_helper = OstApiHelper.new({api_key: @token_secure[:api_key],
                                          api_secret: @token_secure[:api_secret], api_endpoint: @api_endpoint})
      Result.success({})
    end

    # Fetch users from OST
    #
    def fetch_user_from_ost
      response = @ost_api_helper.fetch_user_details({user_id: @token_user[:uuid]})
      unless response[:success]
        return Result.error('a_s_nm_ua_5', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      @user_data_from_ost = response[:data][response[:data][:result_type]]

      if @user_data_from_ost[:token_holder_address].blank?
        return Result.error('a_s_nm_ua_6', 'INVALID_REQUEST',
                            "Token holder contract hasn't been deployed yet")
      end

      Result.success({})
    end

    # Update token user
    #
    def update_token_user
      begin
        token_user_obj = ::TokenUser.where(id: @token_user[:id]).first
        token_user_obj.token_holder_address = @user_data_from_ost[:token_holder_address]
        token_user_obj.device_manager_address = @user_data_from_ost[:device_manager_address]
        token_user_obj.recovery_address = @user_data_from_ost[:recovery_address]
        token_user_obj.ost_user_status = @user_data_from_ost[:status]
        token_user_obj.save! if token_user_obj.changed?
      rescue => e
        Rails.logger.error("update_token_user exception: #{e.message}")
        return Result.error('a_s_nm_ua_7', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      Result.success({})
    end

    # Grant BT to this token user (if eligible)
    #
    def check_eligibility_and_grant_bt

     # if user isn't eligible. return success
      r = check_user_eligibility
      return r unless r[:success]

      r = determine_grant_amount
      return r unless r[:success]

      r = fetch_rule_address_from_ost
      return r unless r[:success]

      r = submit_grant_request_to_ost
      return r unless r[:success]

      Result.success({})

    end

    # Check if this token user lies in the eligibility criteria
    #
    def check_user_eligibility
      count = TokenUser.where(token_id: @token_id, ost_user_status: GlobalConstant::User.activated_ost_user_status).count
      if count > GlobalConstant::Grant.count_of_users_eligible
        return Result.error('a_s_nm_ua_8', 'INVALID_REQUEST', 'Grant user limit breached')
      end
      Result.success({})
    end

    # depending on company reserve balance & other set restrictions, determine the amount to be granted
    #
    def determine_grant_amount

      response = @ost_api_helper.fetch_user_balance({user_id: @token[:pc_token_holder_uuid]})
      unless response[:success]
        return Result.error('a_s_nm_ua_9', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      available_reserve_balance = BigDecimal.new(response[:data][response[:data][:result_type]][:available_balance])

      amount_for_grants = available_reserve_balance * GlobalConstant::Grant.percent_of_balance_to_be_used_for_grant / 100
      grant_amount = amount_for_grants / GlobalConstant::Grant.count_of_users_eligible

      min_bt_smallest_unit_grant_amount = GlobalConstant::Grant.min_bt_smallest_unit_grant_amount(@token[:decimal])
      max_bt_smallest_unit_grant_amount = GlobalConstant::Grant.max_bt_smallest_unit_grant_amount(@token[:decimal])

      if grant_amount < min_bt_smallest_unit_grant_amount
        Rails.logger.error('insufficent min_bt_smallest_unit_grant_amount')
        Rails.logger.info("@token[:decimal]: #{@token[:decimal]}")
        Rails.logger.info("grant_amount: #{grant_amount}")
        Rails.logger.info("min_bt_smallest_unit_grant_amount: #{min_bt_smallest_unit_grant_amount}")
        Rails.logger.info("available_reserve_balance: #{available_reserve_balance}")
        Rails.logger.info("amount_for_grants: #{amount_for_grants}")
        return Result.error('a_s_nm_ua_10', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      if grant_amount > max_bt_smallest_unit_grant_amount
        grant_amount = max_bt_smallest_unit_grant_amount
      end

      @bt_grant_amount_in_wei = grant_amount

      Result.success({})

    end
    
    # Fetch Rule Address from OST
    # 
    def fetch_rule_address_from_ost

      response = @ost_api_helper.fetch_rules
      unless response[:success]
        return Result.error('a_s_nm_ua_11', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      rules_data = response[:data][response[:data][:result_type]]
      rules_data.each do |rule_data|
        if rule_data[:name] == GlobalConstant::Grant.rule_name_to_use_for_grant
          @rule_address_from_ost = rule_data[:address]
          break
        end
      end

      if @rule_address_from_ost.blank?
        return Result.error('a_s_nm_ua_12', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      Result.success({})

    end

    # Submit Grant Request to OST
    #
    def submit_grant_request_to_ost
      execute_params = {
        user_id: @token[:pc_token_holder_uuid],
        to: @rule_address_from_ost
      }
      raw_calldata = {
        method: 'directTransfers',
        parameters: [
          [@user_data_from_ost[:token_holder_address]],
          [@bt_grant_amount_in_wei.truncate.to_s]
        ]
      }
      execute_params[:raw_calldata] = raw_calldata.to_json
      meta_property = {
        name: 'Welcome Airdrop',
        type: 'company_to_user'
      }
      execute_params[:meta_property] = meta_property

      response = @ost_api_helper.initiate_fund_transfer(execute_params)
      unless response[:success]
        return Result.error('a_s_nm_ua_13', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      Result.success({})

    end

    # Final response
    #
    def final_response
      updated_token_user_secure = CacheManagement::TokenUserSecure.new([@token_user[:id]]).fetch()[@token_user[:id]]
      updated_token_user = CacheManagement::TokenUser.new([@token_user[:id]]).fetch()[@token_user[:id]]
      Result.success({
                         result_type: 'current_user',
                         current_user: ResponseEntity::CurrentTokenUser.format(updated_token_user, updated_token_user_secure)
                     })
    end

  end

end