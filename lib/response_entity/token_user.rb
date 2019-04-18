# frozen_string_literal: true
module ResponseEntity

  class TokenUser

    class << self

      def format(token_user)
        {
          app_user_id: token_user[:id],
          username: token_user[:username],
          token_id: token_user[:ost_token_id],
          user_id: token_user[:uuid],
          token_holder_address: token_user[:token_holder_address],
          status: token_user[:ost_user_status],
          uts: token_user[:updated_at].to_i,
          cts: token_user[:created_at].to_i
        }
      end

    end

  end

end