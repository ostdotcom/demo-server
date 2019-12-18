module OstEvents

  module Transaction

    class TransactionSuccess < OstEvents::Transaction::Base

      # Transaction success event constructor.
      def initialize(event_data, request_headers, ost_raw_body)
        super
      end

      # Action on receiving transaction success event.
      def perform
        # Mark ost event as started.
        mark_ost_event_started

        fetch_token_users

        if @token_users.present? and @token_users.map{|x| x.ost_token_id}.uniq.length == 1
          if Token.validate_webhook_signature(@token_users[0].token_id, @ost_raw_body, @request_headers)
            # Update token users table.
            update_token_users

            # Mark transaction as done.
            mark_transaction_done(@transaction_data)


          else
            # Mark ost event as failed.
            mark_ost_event_failed

            return Result.error('a_s_oe_t_ts_1',
                                'INVALID_SIGNATURE',
                                'Unrecognized token or signature.')
          end
        else
          # Mark ost event as failed.
          mark_ost_event_failed

          return Result.error('a_s_oe_t_ts_2',
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
          ost_user_ids = @transfers.map{|x|x[:from_user_id]}
          @token_users = TokenUser.where(uuid: ost_user_ids).all
        end
      end

      def update_token_users
        @token_users.each do |tu|
          if tu.ost_user_status == "ACTIVATED" && !tu.first_transaction_ts.present?
            tu.first_transaction_ts = Time.now.to_i
            tu.save!
          end
        end
      end

    end

  end

end
