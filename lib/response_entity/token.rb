# frozen_string_literal: true
module ResponseEntity

  class Token

    class << self

      def format(token)
        {
          id: token[:id],
          ost_token_id: token[:ost_token_id],
          name: token[:name],
          symbol: token[:symbol],
          conversion_factor: token[:conversion_factor],
          pc_token_holder_uuid: token[:pc_token_holder_uuid],
          updated_at: token[:updated_at],
          created_at: token[:created_at],
        }
      end

    end

  end

end