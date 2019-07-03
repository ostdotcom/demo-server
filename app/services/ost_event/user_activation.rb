module OstEvent
  class UserActivation

    # User Activation event constructor
    def initialize(event_data, request_headers)
      @event_data = event_data
      @ost_user = event_data["user"]
      @request_headers = request_headers

      @token_user = nil
      @token = nil
    end

    # Action on receiving user activation event
    def perform

      r = fetch_token_user
      return r unless r.success?

      if @token_user.present?
        r = Token.validate_webhook_signature(@token.id, @event_data, @request_headers)
        return r unless r.success?

        return NotificationManagement::UserActivate.new({token_user: @token_user, token: @token,
                                                         user_data_from_ost: @ost_user}).perform
      end

      Result.success({})

    end

    private

    def fetch_token_user
      user = TokenUser.where(uuid: @ost_user["id"]).first

      # If token user is known then only update its activation status only if its status is created
      if user.present? && user.ost_token_id == @ost_user["token_id"] && user.ost_user_status == 'CREATED'
        @token_user = user
        @token = Token.where(id: @token_user.token_id).first
      else
        return Result.error('a_s_oe_ua_1',
                            'INVALID_REQUEST',
                            'Unrecognized User data')
      end

      Result.success({})
    end

  end
end