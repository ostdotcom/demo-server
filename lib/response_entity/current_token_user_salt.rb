# frozen_string_literal: true
module ResponseEntity

  class CurrentTokenUserSalt

    class << self

      def format(token_user, user_salts)
        {
          app_user_id: token_user[:id],
          user_id: token_user[:uuid],
          recovery_pin_salt: user_salts[:recovery_pin_salt],
          cts: user_salts[:created_at].to_i,
          uts: user_salts[:updated_at].to_i
        }
      end

    end

  end

end