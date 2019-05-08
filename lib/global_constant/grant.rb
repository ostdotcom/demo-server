# frozen_string_literal: true
module GlobalConstant

  class Grant

    class << self

      def eligible_ost_user_status
        'ACTIVATED'
      end

      def count_of_users_eligible
        10
      end

      # This is the percentage of company reserve's current balance, which could be used for grant
      # This amount to be equally divided amount count_of_users_eligible and to be checked against
      # min_bt_grant_amount & max_bt_grant_amount
      def percent_of_balance_to_be_used_for_grant
        10
      end

      def min_bt_wei_grant_amount
        BigDecimal.new('1') * wei_multiplication_factor
      end

      def max_bt_wei_grant_amount
        BigDecimal.new('10') * wei_multiplication_factor
      end

      def wei_multiplication_factor
        BigDecimal.new('1000000000000000000')
      end

      def rule_name_to_use_for_grant
        'Direct Transfer'
      end

    end

  end

end