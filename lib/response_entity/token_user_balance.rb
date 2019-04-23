# frozen_string_literal: true
module ResponseEntity

  class TokenUserBalance

    class << self

      def format(token_user_data, balance_data)
        {
          app_user_id: token_user_data[:id],
          user_id: token_user_data[:uuid],
          total_balance: balance_data[:total_balance],
          available_balance: balance_data[:available_balance],
          unsettled_debit: balance_data[:unsettled_debit],
          uts: balance_data[:updated_timestamp]
        }
      end

    end

  end

end