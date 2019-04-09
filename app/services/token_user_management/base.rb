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
      @q.strip!
      @page = 1 if @page <= 1

      Result.success({})
    end

  end

end