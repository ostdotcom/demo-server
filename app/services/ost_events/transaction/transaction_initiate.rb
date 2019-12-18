module OstEvents

  module Transaction

    class TransactionInitiate < OstEvents::Transaction::Base

      # Transaction initiate event constructor.
      def initialize(event_data, request_headers)
        super
      end

      # Action on receiving transaction initiate event.
      def perform
        # Mark ost event as started.
        mark_ost_event_started

        fetch_token_users

        if @token_users.present? and @token_users.map{|x| x.ost_token_id}.uniq.length == 1
          if Token.validate_webhook_signature(@token_users[0].token_id, @event_data, @request_headers)
            # Create an entry in transactions table.
            create_entry_in_transactions

            # Create entry in user transactions table.
            create_entry_in_user_transactions
          else
            # Mark ost event as failed.
            mark_ost_event_failed

            return Result.error('a_s_oe_t_ti_1',
                                'INVALID_SIGNATURE',
                                'Unrecognized token or signature.')
          end
        else
          # Mark ost event as failed.
          mark_ost_event_failed

          return Result.error('a_s_oe_t_ti_2',
                              'INVALID_REQUEST',
                              'Unrecognized users data.')
        end

        # Mark ost event as done.
        mark_ost_event_done

        Result.success({})
      end

      private

      def fetch_token_users
        if @transfers.present? && @transfers.length > 0
          uuids_set = Set.new([])
          @transfers.each do |transfer|
            uuids_set.add(transfer[:from_user_id]) if transfer[:from_user_id].present?
            uuids_set.add(transfer[:to_user_id]) if transfer[:to_user_id].present?
          end

          # Convert to array.
          @uuids_array = uuids_set.to_a
          @token_users = TokenUser.where(uuid: @uuids_array[0]).all
        end
      end

      def create_entry_in_user_transactions
        token_user_data_by_uuid = CacheManagement::TokenUserByUuid.new(@uuids_array).fetch()

        # Fetch token user id for the given ost-user-ids.
        token_user_ids = []
        @uuids_array.each do |uuid|
          if token_user_data_by_uuid[uuid].present?
            token_user_ids.push(token_user_data_by_uuid[uuid][:id])
          end
        end

        # Create entries for all the involved users.
        token_user_ids.each do |token_user_id|
          UserTransaction.new({
                                token_user_id: token_user_id,
                                transaction_id: @transaction_obj[:id]
                              }).save!
        end
      end

    end

  end

end
