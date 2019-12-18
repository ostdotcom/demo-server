module OstEvents

  module Transaction

    class Base < ::OstEvents::Base

      def initialize(event_data, request_headers)
        super

        @transaction_data = event_data[:data][:transaction]
        @transfers = @transaction_data[:transfers]

        @token_users = []
      end

      def create_entry_in_transactions
        begin
          @transaction_obj = ::Transaction.new({
                                               ost_tx_id: @transaction_data[:id],
                                               status: GlobalConstant::Transactions.pending_status,
                                               transaction_data: @transaction_data
                                             })

          @transaction_obj.save!
        rescue => e
          Rails.logger.info("Transaction entry already exists. Transaction: #{@transaction_data}. Error: #{e}")
        end
      end

      def mark_transaction_done(transaction_data)
        ::Transaction.new.update_status(@transaction_data[:id], GlobalConstant::Transactions.done_status, transaction_data)
      end

      def mark_transaction_failed(transaction_data)
        ::Transaction.new.update_status(@transaction_data[:id], GlobalConstant::Transactions.failed_status, transaction_data)
      end

    end

  end

end
