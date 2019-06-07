module TokenUserManagement

  class List

    # Get Token Users List Constructor
    #
    def initialize(params)
      @token = params[:token]
      @token_id = @token[:id]
      @q = params[:q]
      @app_user_ids = params[:app_user_ids]
      @page = params[:page]
      @limit = 15

      @token_secure = nil
      @api_endpoint = nil
      @ost_api_helper = nil
      @users = []
      @async_tasks = []
      @balances = {}
      @async_tasks_errors = {
        fetch_balance_from_ost: {}
      }
      @has_next_page = false
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      r = set_ost_api_helper
      return r unless r[:success]

      # fetch users from DB and append fetch balance API calls to @async_tasks
      get_users_and_balances

      # fetch price points from OST
      @async_tasks.push(fetch_price_points_from_ost)

      @async_tasks.each { |thread| thread.join } # wait for the slowest one to complete

      if @async_tasks_errors[:fetch_balance_from_ost].present? || @async_tasks_errors[:fetch_price_points_from_ost].present?
        Rails.logger.error("@async_tasks_errors: #{@async_tasks_errors}")
        return Result.error('a_s_tum_l_4', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end
      
      final_response
      
    end

    private

    # validate params
    #
    def validate_params
      r = validate_page
      return r unless r[:success]

      r = validate_search_term
      return r unless r[:success]

      r = validate_app_user_ids
      return r unless r[:success]

      Result.success({})
    end

    # validate page
    #
    def validate_page
      if @page.present?
        return Result.error('a_s_tum_l_1', 'INVALID_REQUEST', 'Invalid page') unless Validator.is_numeric?(@page)
        @page = @page.to_i
        return Result.error('a_s_tum_l_2', 'INVALID_REQUEST', 'Invalid page') if @page < 1
      else
        @page = 1
      end
      Result.success({})
    end

    # validate search term
    #
    def validate_search_term
      if @q.present?
        return Result.error('a_s_tum_l_3', 'INVALID_REQUEST', 'Invalid search term') unless Validator.is_alphanumeric?(@q)
        @q.strip!
      end
      Result.success({})
    end

    # validate app user ids
    #
    def validate_app_user_ids
      if @app_user_ids.present?
        # as this is a JSON stringified version, parse it
        @app_user_ids = JSON.parse(@app_user_ids)
        unless Validator.is_array?(@app_user_ids)
          return Result.error('a_s_tum_l_8', 'INVALID_REQUEST', 'Invalid app user ids')
        end
        if @app_user_ids.length > 100
          return Result.error('a_s_tum_l_9', 'INVALID_REQUEST', 'Invalid app user ids. Max 100 allowed.')
        end
        @app_user_ids.each do |app_user_id|
          unless Validator.is_numeric?(app_user_id)
            return Result.error('a_s_tum_l_10', 'INVALID_REQUEST', 'Invalid app user ids')
          end
        end
      else
        @app_user_ids = []
      end
      Result.success({})
    end

    # Set OST API Helper Object
    #
    def set_ost_api_helper
      r = fetch_token_secure
      return r unless r[:success]

      r = fetch_api_endpoint
      return r unless r[:success]

      @ost_api_helper = OstApiHelper.new({api_key: @token_secure[:api_key],
                                          api_secret: @token_secure[:api_secret], api_endpoint: @api_endpoint})
      Result.success({})
    end

    # Fetch Token Secure data
    #
    def fetch_token_secure
      @token_secure = CacheManagement::TokenSecureById.new([@token_id]).fetch()[@token_id]
      return Result.error('a_s_tum_l_4',
                          'INVALID_REQUEST',
                          'Invalid token') if @token_secure.blank?
      Result.success({})
    end

    # Fetch API Endpoint
    #
    def fetch_api_endpoint
      @api_endpoint = ApiEndpoint.id_to_endpoint_map[@token[:api_endpoint_id]]
      return Result.error('a_s_tum_l_5',
                          'INVALID_REQUEST',
                          'Invalid token') if @api_endpoint.blank?
      Result.success({})
    end

    # Get list of users and then call OST API's to fetch balances
    #
    def get_users_and_balances
      begin
        token_user_ar = ::TokenUser.where(token_id: @token[:id])
        token_user_ar = token_user_ar.where("username LIKE ?", "%#{@q}%") if @q.present?
        token_user_ar = token_user_ar.where(id: @app_user_ids) if @app_user_ids.present?
        token_user_ar = token_user_ar.limit(@limit+1).offset((@page-1)*@limit).order(:username)
        token_user_ar.all.each_with_index do |token_user, index|
          if index == @limit
            @has_next_page = true
            break
          end
          @users << ResponseEntity::TokenUser.format(token_user)
          if token_user[:ost_user_status] == GlobalConstant::User.activated_ost_user_status
            @async_tasks.push(fetch_balance_from_ost(token_user))
          end
        end
      rescue => e
        Rails.logger.error("get_users_and_balances exception: #{e.message}")
        return Result.error('a_s_tum_l_6', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end
      Result.success({})
    end

    # Fetch balance from OST
    #
    def fetch_balance_from_ost(token_user)
      Thread.new {
        response = @ost_api_helper.fetch_user_balance({user_id: token_user[:uuid]})
        if response[:success]
          balance_data = response[:data][response[:data][:result_type]]
          @balances[token_user[:id]] = ResponseEntity::TokenUserBalance.format(token_user, balance_data)
        else
          @async_tasks_errors[:fetch_balance_from_ost][token_user[:uuid]] = response
          Rails.logger.error("fetch_balance_from_ost error for #{token_user[:uuid]} response : #{response}")
        end
      }
    end
    
    # Fetch price points from OST
    #
    def fetch_price_points_from_ost
      Thread.new {
        response = @ost_api_helper.fetch_price_points({chain_id: @token[:chain_id]})
        if response[:success]
          @ost_price_point_data = response[:data][response[:data][:result_type]]
        else
          @async_tasks_errors[:fetch_price_points_from_ost] = Result.error('a_s_tum_l_7', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
        end
      }
    end
    
    # final response
    #
    def final_response
      meta = {next_page_payload: {}}
      if @has_next_page
        meta[:next_page_payload] = {page: @page + 1}
        meta[:next_page_payload][:q] = @q if @q.present?
      end
      Result.success({result_type: 'users', users: @users, meta: meta,
                      balances: @balances, price_point: @ost_price_point_data})
    end

  end

end