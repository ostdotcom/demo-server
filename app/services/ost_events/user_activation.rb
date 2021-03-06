module OstEvents

  class UserActivation < OstEvents::Base

    # User activation event constructor.
    def initialize(event_data, request_headers, ost_raw_body)
      super

      @ost_user = event_data[:data][:user]

      @token_user = nil
      @token = nil
    end

    # Action on receiving user activation event.
    def perform
      # Mark ost event as started.
      mark_ost_event_started

      r = fetch_token_user
      return r unless r[:success]

      if @token_user.present?
        if Token.validate_webhook_signature(@token.id, @ost_raw_body, @request_headers)
          return NotificationManagement::UserActivate.new({token_user: @token_user, token: @token,
                                                           user_data_from_ost: @ost_user}).perform
        end
          # Mark ost event as failed.
          mark_ost_event_failed

          return Result.error('a_s_oe_ua_1',
                              'INVALID_SIGNATURE',
                              'Unrecognized token or signature.')
      end

      # Mark ost event as done.
      mark_ost_event_done

      Result.success({})

    end

    private

    def fetch_token_user
      user = TokenUser.where(uuid: @ost_user[:id]).first

      # If token user is known then only update its activation status only if its status is created.
      if user.present? && user.ost_token_id == @ost_user[:token_id] && user.ost_user_status == 'CREATED'
        @token_user = user
        @token = Token.where(id: @token_user.token_id).first
      else
        # Mark ost event as failed.
        mark_ost_event_failed

        return Result.error('a_s_oe_ua_2',
                            'INVALID_REQUEST',
                            'Unrecognized user data.')
      end

      Result.success({})
    end

  end
end
