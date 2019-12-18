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

      def webhook_topics
        ['transactions/initiate', 'transactions/success', 'transactions/failure', 'transactions/mine', 'users/activation_initiate', 'users/activation_success', 'users/activation_failure', 'price_points/usd_update', 'price_points/eur_update', 'price_points/gbp_update' ]
      end

      def webhook_subscription_endpoint
        GlobalConstant::Base.demo_endpoint + '/api/ost-wallet-test-webhook'
      end
    end

  end

end
