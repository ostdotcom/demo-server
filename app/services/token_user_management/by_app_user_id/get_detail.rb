module TokenUserManagement

  module ByAppUserId

    class GetDetail < TokenUserManagement::ByAppUserId::Base

      # Get User Detail by app user id Constructor
      #
      def initialize(params)
        super
      end

      # Perform action
      #
      def perform
        r = validate_params
        return r unless r[:success]

        r = get_user_detail
        return r unless r[:success]

        final_response
      end

      private

      # final response
      #
      def final_response
        Result.success({result_type: 'user', user: ResponseEntity::TokenUser.format(@token_user)})
      end

    end

  end

end