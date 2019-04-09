# frozen_string_literal: true
module ResponseEntity

  class CurrentTokenUser

    class << self

      def format(token_user, token_user_secure)
        {
          app_user_id: token_user[:id],
          fullname: token_user[:fullname],
          token_id: token_user[:ost_token_id],
          user_id: token_user[:uuid],
          token_holder_address: token_user[:token_holder_address],
          device_manager_address: token_user[:device_manager_address],
          recovery_address: token_user[:recovery_address],
          user_pin_salt: token_user_secure[:user_pin_salt],
          status: token_user[:ost_user_status],
          updated_at: token_user[:updated_at],
          created_at: token_user[:created_at]
        }
      end

    end

  end

end