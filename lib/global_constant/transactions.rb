# frozen_string_literal: true
module GlobalConstant

  class Transactions

    class << self
      # Transactions status starts.
      def pending_status
        'pending'
      end

      def done_status
        'done'
      end

      def failed_status
        'failed'
      end
      # Transactions status ends.
    end

  end

end
