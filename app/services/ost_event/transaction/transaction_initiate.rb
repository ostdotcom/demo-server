module OstEvent

  class TransactionInitiate < OstEventsTransactionsBase

    # Transaction initiate event constructor.
    def initialize(event_data, request_headers)
      super

      @transfers = @transaction_data["transfers"]

      @token_users = []
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
        ost_user_ids = @transfers.map{|x|x["from_user_id"]}
        @token_users = TokenUser.where(uuid: ost_user_ids).all
      end
    end

    def create_entry_in_user_transactions
      UserTransaction.new({
        token_user_id: @token_users[0].id,
        transaction_id: @transaction_obj.id,
        transaction_ts: @transaction_data.updated_timestamp
                          }).save!
    end

  end
end
