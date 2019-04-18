module TokenUserManagement

  class List

    # Get Token Users List Constructor
    #
    def initialize(params)
      @token = params[:token]
      @q = params[:q]
      @page = params[:page]
      @limit = 25

      @users = []
      @has_next_page = false
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      r = get_users
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

    # Get list of users
    #
    def get_users
      begin
        token_user_ar = ::TokenUser.where(token_id: @token[:id])
        token_user_ar = token_user_ar.where("username LIKE ?", "%#{@q}%") if @q.present?
        token_user_ar = token_user_ar.limit(@limit+1).offset((@page-1)*@limit).order(:username)
        token_user_ar.all.each_with_index do |token_user, index|
          if (index+1) == @limit
            @has_next_page = true
            break
          end
          @users << ResponseEntity::TokenUser.format(token_user)
        end
      rescue => e
        Rails.logger.error("get_users exception: #{e.message}")
        return Result.error('a_s_tum_l_4', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end
      Result.success({})
    end

    # final response
    #
    def final_response
      meta = {}
      if @has_next_page
        meta[:next_page_payload] = {page: @page + 1}
        meta[:next_page_payload][:q] = @q if @q.present?
      end
      Result.success({result_type: 'users', users: @users, meta: meta})
    end

  end

end