module OstEvent
  class UserActivation

    # User Activation event constructor
    def initialize(params)
      @ost_user = params.user
    end

    # Action on receiving user activation event
    def perform

      fetch_token_user

      if @token_user.present?
        return update_token_user
      end

      Result.success({})

    end

    private

    def fetch_token_user
      user = TokenUser.where(uuid: @ost_user.id).first

      # If token user is known then only update its activation status only if its status is created
      if user.present? && user.ost_token_id == @ost_user.token_id && user.ost_user_status == 'CREATED'
        @token_user = user
      end
    end

    # Update token user
    #
    def update_token_user
      begin
        @token_user.token_holder_address = @ost_user[:token_holder_address]
        @token_user.device_manager_address = @ost_user[:device_manager_address]
        @token_user.recovery_address = @ost_user[:recovery_address]
        @token_user.ost_user_status = @ost_user[:status]
        @token_user.ost_activation_ts = Time.now.to_i
        @token_user.save! if @token_user.changed?
      rescue => e
        Rails.logger.error("update_token_user exception: #{e.message}")
        return Result.error('a_s_oe_ua_1', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
      end

      Result.success({})
    end

  end
end