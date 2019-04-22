module TokenUserManagement

  module ByAppUserId

    class GetBalance < TokenUserManagement::ByAppUserId::Base

      # Get User Balance by app user id Constructor
      #
      def initialize(params)
        super
        @balance_from_ost = nil
      end

      # Perform action
      #
      def perform
        r = validate_params
        return r unless r[:success]

        r = get_user_detail
        return r unless r[:success]

        r = set_ost_api_helper
        return r unless r[:success]

        r = fetch_balance_from_ost
        return r unless r[:success]

        final_response
      end

      private

      # Get user detail
      #
      def get_user_detail
        r = super
        return r unless r[:success]
        if @token_user[:ost_user_status] != GlobalConstant::User.activated_ost_user_status
          return Result.error('a_s_tum_baui_gb_1', 'INVALID_REQUEST', "User hasn't been activated yet")
        end
        Result.success({})
      end

      # fetch balance from OST
      #
      def fetch_balance_from_ost
        response = @ost_api_helper.fetch_user_balance({user_id: @token_user[:uuid]})
        unless response[:success]
          return Result.error('a_s_tum_baui_gb_2', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
        end
        @balance_from_ost = response[:data][response[:data][:result_type]]
        Result.success({})
      end

      # final response
      #
      def final_response
        Result.success({result_type: 'balance', balance: ResponseEntity::TokenUserBalance.format(@balance_from_ost)})
      end

    end

  end

end