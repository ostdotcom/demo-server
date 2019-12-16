# frozen_string_literal: true
module GlobalConstant

  class OstEvents

    class << self
      # Ost events status starts.
      def pending_status
        'pending'
      end

      def started_status
        'started'
      end

      def done_status
        'done'
      end

      def failed_status
        'failed'
      end
      # Ost events status ends.
    end

  end

end
