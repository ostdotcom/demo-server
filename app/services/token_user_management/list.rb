module TokenUserManagement

  class List < TokenUserManagement::Base

    # Get Token Users List Constructor
    #
    def initialize(params)
      super(params)
    end

    # Perform action
    #
    def perform
      r = validate_params
      return r unless r[:success]

      get_users
    end

    private

    # validate params
    #
    def validate_params
      r = super
      return r unless r[:success]

      Result.success({})
    end

    # Get list of users
    #
    def get_users
      users = []

      begin
        token_user_ar = ::TokenUser.where(token_id: @token[:id])
        token_user_ar = token_user_ar.where("fullname LIKE ?", "%#{@q}%") if @q.present?
        token_user_ar = token_user_ar.limit(@limit).offset((@page-1)*@limit).order(:fullname)
        token_user_ar.all.each do |token_user|
          users << ResponseEntity::TokenUser.format(token_user)
        end
      rescue => e
        Rails.logger.error("get_users exception: #{se.message}")
        return Result.error('a_s_tum_l_1', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      Result.success({result_type: 'users', users: users})
    end

  end

end