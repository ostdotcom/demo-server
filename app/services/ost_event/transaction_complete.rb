module OstEvent
  class TransactionComplete

    # Transaction complete event constructor
    def initialize(event_data)
      @transaction_data = event_data["transaction"]

      @transfers = @transaction_data["transfers"]

      @token_users = []
    end

    # Action on receiving transaction complete event
    def perform

      fetch_token_users

      if @token_users.present?
        update_token_users
      end

      Result.success({})

    end

    private

    def fetch_token_users
      if @transfers.present? && @transfers.length > 0
        ost_user_ids = @transfers.map{|x|x["from_user_id"]}
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