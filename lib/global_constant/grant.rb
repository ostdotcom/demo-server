# frozen_string_literal: true
module GlobalConstant

  class Grant

    class << self

      def eligible_ost_user_status
        'ACTIVATED'
      end

      def count_of_users_eligible
        100
      end

      # This is the percentage of company reserve's current balance, which could be used for grant
      # This amount to be equally divided amount count_of_users_eligible and to be checked against
      # min_bt_grant_amount & max_bt_grant_amount
      def percent_of_balance_to_be_used_for_grant
        80
      end

      def min_bt_smallest_unit_grant_amount(decimals)
        BigDecimal.new('0.01') * smallest_unit_multiplication_factor(decimals)
      end

      def max_bt_smallest_unit_grant_amount(decimals)
        BigDecimal.new('10') * smallest_unit_multiplication_factor(decimals)
      end

      def smallest_unit_multiplication_factor(decimals)
        BigDecimal.new('10').power(decimals)
      end

      def rule_name_to_use_for_grant
        'Direct Transfer'
      end

    end

  end

end