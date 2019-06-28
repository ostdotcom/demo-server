module TokenManagement
  class GetStats

    # Constructor to get token stats
    #
    # params[:stats_post_ts] - Timestamp after which stats is needed.
    # params[:api_endpoint_id]
    #
    def initialize(params)
      @stats_post_ts = params[:stats_post_ts] || (Time.now.beginning_of_day).to_i
      @api_endpoint_id = ApiEndpoint.endpoint_to_id_map[params[:api_endpoint_id]]
    end

    # Get stats
    def perform
      token_ids = Token.where(api_endpoint_id: @api_endpoint_id).all.map{|x| x.id}

      lifetime_user_activated_records = {}
      user_activated_records_post_ts = {}
      lifetime_trx_records = {}
      trx_records_post_ts = {}
      if token_ids.length > 0
        # Fetch all activated users count
        TokenUser.select("id, ost_token_id, count(*) AS total_users").
            where('ost_activation_ts IS NOT NULL').
            group(:ost_token_id).all.each{|x| lifetime_user_activated_records[x.ost_token_id] = x.total_users }

        # Fetch all activated users after the specified timestamp
        TokenUser.select("id, ost_token_id, count(*) AS total_users").
            where('ost_activation_ts > ?', @stats_post_ts).
            group(:ost_token_id).all.each{|x| user_activated_records_post_ts[x.ost_token_id] = x.total_users }

        # Fetch transactions completed of distinct users
        TokenUser.select("id, ost_token_id, count(*) AS total_transactions").
            where('first_transaction_ts IS NOT NULL').
            group(:ost_token_id).all.each{|x| lifetime_trx_records[x.ost_token_id] = x.total_transactions }

        # Fetch all transactions completed of distinct users after specified timestamp
        TokenUser.select("id, ost_token_id, count(*) AS total_transactions").
                  where('first_transaction_ts > ?', @stats_post_ts).
                  group(:ost_token_id).all.each{|x| trx_records_post_ts[x.ost_token_id] = x.total_transactions }
      end

      Result.success({lifetime_user_activated_records: lifetime_user_activated_records,
                            user_activated_records_post_ts: user_activated_records_post_ts,
                            lifetime_trx_records: lifetime_trx_records,
                            trx_records_post_ts: trx_records_post_ts
                     })
    end

  end
end