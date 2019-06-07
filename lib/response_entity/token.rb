# frozen_string_literal: true
module ResponseEntity

  class Token

    class << self

      def format(token_data_from_db, token_data_from_ost)
        {
          id: token_data_from_db[:id],
          name: token_data_from_db[:name],
          symbol: token_data_from_db[:symbol],
          conversion_factor: token_data_from_db[:conversion_factor],
          pc_token_holder_uuid: token_data_from_db[:pc_token_holder_uuid],
          chain_id: token_data_from_db[:chain_id],
          uts: token_data_from_db[:updated_at].to_i,
          cts: token_data_from_db[:created_at].to_i,
          ost_token_id: token_data_from_ost[:id],
          decimals: token_data_from_ost[:decimals],
          total_supply: token_data_from_ost[:total_supply],
          utility_branded_token_address: token_data_from_ost[:auxiliary_chains].first[:utility_branded_token],
          value_branded_token_address: token_data_from_ost[:origin_chain][:branded_token]
        }
      end

    end

  end

end