module TokenUserManagement

  class Base

    # Token User Management Constructor
    #
    def initialize(params)
      @token = params[:token]
      @q = params[:q]
      @page = params[:page]
      @limit = 25
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
        return Result.error('a_s_tum_b_1', 'INVALID_REQUEST', 'Invalid page') unless Validator.is_numeric?(@page)
        @page = @page.to_i
        return Result.error('a_s_tum_b_2', 'INVALID_REQUEST', 'Invalid page') if @page < 1
      else
        @page = 1
      end
      Result.success({})
    end

    # validate search term
    #
    def validate_search_term
      if @q.present?
        return Result.error('a_s_tum_b_3', 'INVALID_REQUEST', 'Invalid page') unless Validator.is_alpha_space?(@q)
        @q.strip!
      end
      Result.success({})
    end

  end

end