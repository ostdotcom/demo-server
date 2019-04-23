module TokenUserManagement

  class List

    # Get Token Users List Constructor
    #
    def initialize(params)
      @token = params[:token]
      @token_id = @token[:id]
      @q = params[:q]
      @page = params[:page]
      @limit = 25

      @token_secure = nil
      @api_endpoint = nil
      @ost_api_helper = nil
      @users = []
      @balances = {}
      @balance_fetch_errors = {}
      @has_next_page = false
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      r = set_ost_api_helper
      return r unless r[:success]

      r = get_users_and_balances
      return r unless r[:success]

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
        return Result.error('a_s_tum_l_3', 'INVALID_REQUEST', 'Invalid page') unless Validator.is_alpha_space?(@q)
        @q.strip!
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
      return Result.error('a_s_tum_fliu_gl_1',
                          'INVALID_REQUEST',
                          'Invalid token') if @token_secure.blank?
      Result.success({})
    end

    # Fetch API Endpoint
    #
    def fetch_api_endpoint
      @api_endpoint = ApiEndpoint.id_to_endpoint_map[@token[:api_endpoint_id]]
      return Result.error('a_s_tum_fliu_gl_2',
                          'INVALID_REQUEST',
                          'Invalid token') if @api_endpoint.blank?
      Result.success({})
    end

    # Get list of users and then call OST API's to fetch balances
    #
    def get_users_and_balances
      begin
        fetch_balance_tasks = []
        token_user_ar = ::TokenUser.where(token_id: @token[:id])
        token_user_ar = token_user_ar.where("username LIKE ?", "%#{@q}%") if @q.present?
        token_user_ar = token_user_ar.limit(@limit+1).offset((@page-1)*@limit).order(:username)
        token_user_ar.all.each_with_index do |token_user, index|
          if (index+1) == @limit
            @has_next_page = true
            break
          end
          @users << ResponseEntity::TokenUser.format(token_user)
          if token_user[:ost_user_status] == GlobalConstant::User.activated_ost_user_status
            fetch_balance_tasks.push(fetch_balance_from_ost(token_user))
          end
        end

        fetch_balance_tasks.each { |thread| thread.join } # wait for the slowest one to complete

        if @balance_fetch_errors.present?
          Rails.logger.error("@balance_fetch_errors: #{@balance_fetch_errors}")
          return Result.error('a_s_tum_l_4', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
        end

      rescue => e
        Rails.logger.error("get_users_and_balances exception: #{e.message}")
        return Result.error('a_s_tum_l_5', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
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
          @balance_fetch_errors[token_user[:uuid]] = response
          Rails.logger.error("fetch_balance_from_ost error for #{token_user[:uuid]} response : #{response}")
        end
      }
    end

    # final response
    #
    def final_response
      meta = {}
      if @has_next_page
        meta[:next_page_payload] = {page: @page + 1}
        meta[:next_page_payload][:q] = @q if @q.present?
      end
      Result.success({result_type: 'users', users: @users, balances: @balances, meta: meta})
    end

  end

end