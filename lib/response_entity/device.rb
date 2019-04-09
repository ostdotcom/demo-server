# frozen_string_literal: true
module ResponseEntity

  class Device

    class << self

      def format(token_user, device)
        {
          app_user_id: token_user[:id],
          user_id: device[:user_id],
          address: device[:address],
          api_signer_address: device[:api_signer_address],
          status: device[:status]
        }
      end

    end

  end

end