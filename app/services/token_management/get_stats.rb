module TokenManagement
  class GetStats

    # Constructor to get token stats
    #
    # params[stats_post_ts] - Timestamp after which stats is needed.
    #
    def initialize(params)
      @stats_post_ts = params[:stats_post_ts] || (Time.now.beginning_of_day).to_i
    end

    # Get stats
    def perform
      # Fetch all token users
      lifetime_user_activated_records = {}
      TokenUser.select("id, ost_token_id, count(*) AS total_users").
          where('ost_activation_ts IS NOT NULL').
          group(:ost_token_id).all.each{|x| lifetime_user_activated_records[x.ost_token_id] = x.total_users }

      user_activated_records_post_ts = {}
      TokenUser.select("id, ost_token_id, count(*) AS total_users").
          where('ost_activation_ts > ?', @stats_post_ts).
          group(:ost_token_id).all.each{|x| user_activated_records_post_ts[x.ost_token_id] = x.total_users }

      lifetime_trx_records = {}
      TokenUser.select("id, ost_token_id, count(*) AS total_transactions").
          where('first_transaction_ts IS NOT NULL').
          group(:ost_token_id).all.each{|x| lifetime_trx_records[x.ost_token_id] = x.total_transactions }

      trx_records_post_ts = {}
      TokenUser.select("id, ost_token_id, count(*) AS total_transactions").
          where('first_transaction_ts > ?', @stats_post_ts).
          group(:ost_token_id).all.each{|x| trx_records_post_ts[x.ost_token_id] = x.total_transactions }

      Result.success({lifetime_user_activated_records: lifetime_user_activated_records,
                            user_activated_records_post_ts: user_activated_records_post_ts,
                            lifetime_trx_records: lifetime_trx_records,
                            trx_records_post_ts: trx_records_post_ts
                     })
    end

  end
end