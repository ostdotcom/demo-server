# One timer script to populate all transactions.
#
# * Author: Alpesh
# * Date: 18/12/2019
# * Reviewed By:
#
namespace :one_timers do

  desc "Usage: rake RAILS_ENV=staging one_timers:populate_transactions"

  task :populate_transactions => :environment do

    tx_status = {
      "SUCCESS" => GlobalConstant::Transactions.done_status,
      "FAILED" => GlobalConstant::Transactions.failed_status
    }


    tx_id = 1000000-1
    user_tx_id = 1000000-1

    Token.all.each {|token_obj|

      p "token-----------------#{token_obj.inspect}"
      token_id = token_obj.id
      token_secure = CacheManagement::TokenSecureById.new([token_id]).fetch()[token_id]
      api_endpoint = ApiEndpoint.id_to_endpoint_map[token_obj[:api_endpoint_id]]
      ost_api_helper = OstApiHelper.new({api_key: token_secure[:api_key],
                                         api_secret: token_secure[:api_secret], api_endpoint: api_endpoint})

      TokenUser.where(token_id: token_id).all.each {|tu|

        pagination_identifier = nil

        while 1

          fetch_ledger_params = {user_id: tu[:uuid]}
          if pagination_identifier.present?
            fetch_ledger_params[:pagination_identifier] = pagination_identifier
          end

          response = ost_api_helper.fetch_user_transaction_ledger(fetch_ledger_params)
          unless response[:success]
            p "-----tu-----------------#{tu.inspect}"
            p "-----response-----------------#{response.inspect}"
            break
          end
          api_response = response[:data]

          break if api_response[api_response[:result_type]].blank?

          api_response[api_response[:result_type]].each do |transaction|
            status = tx_status[transaction[:status]] || GlobalConstant::Transactions.pending_status
            tx_time = Time.at(transaction[:updated_timestamp])
            created_at = tx_time.strftime("%Y-%m-%d %H:%M:%S")
            begin
              transaction_obj = Transaction.create!(
                id: tx_id,
                ost_tx_id: transaction[:id],
                status: status,
                transaction_data: transaction,
                created_at: created_at,
                updated_at: created_at
              )
              tx_id = tx_id-1
            rescue Exception => e
              p "transaction-----------------#{transaction}"
              next
            end

            uuids_set = Set.new([])
            transaction[:transfers].each do |transfer|
              uuids_set.add(transfer[:from_user_id]) if transfer[:from_user_id].present?
              uuids_set.add(transfer[:to_user_id]) if transfer[:to_user_id].present?
            end
            uuids_array = uuids_set.to_a
            if uuids_array.present?
              token_user_data_by_uuid = CacheManagement::TokenUserByUuid.new(uuids_array).fetch()
              token_user_data_by_uuid.each {|uuid, token_user|
                token_user_id = token_user[:id]
                next if token_user_id.blank?
                UserTransaction.create!(
                  id: user_tx_id,
                  token_user_id: token_user_id,
                  transaction_id: transaction_obj.id,
                  created_at: created_at,
                  updated_at: created_at
                )
                user_tx_id = user_tx_id - 1
              }
            end

          end
          pagination_identifier = api_response[:meta][:next_page_payload][:pagination_identifier]
          break unless pagination_identifier

        end

      }

    }

  end

end