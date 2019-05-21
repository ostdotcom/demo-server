module TokenUserManagement

  module ByAppUserId

    class GetBalance < TokenUserManagement::ByAppUserId::Base

      # Get User Balance by app user id Constructor
      #
      def initialize(params)
        super
        @balance_from_ost = nil
        @ost_price_point_data = nil
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

        tasks = []
        tasks.push(fetch_balance_from_ost)
        tasks.push(fetch_price_points_from_ost)

        tasks.each { |thread| thread.join } # wait for the slowest one to complete

        # iterate over tasks to check if any of them had failed
        tasks.each do |task|
          return r unless task.value[:success]
        end

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

      # Fetch price points from OST
      #
      def fetch_price_points_from_ost
        Thread.new {
          response = @ost_api_helper.fetch_price_points({chain_id: @token[:chain_id]})
          if response[:success]
            @ost_price_point_data = response[:data][response[:data][:result_type]]
            Thread.current[:output] = Result.success({})
          else
            Thread.current[:output] = Result.error('a_s_tum_baui_gb_2', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
          end
        }
      end

      # fetch balance from OST
      #
      def fetch_balance_from_ost
        Thread.new {
          response = @ost_api_helper.fetch_user_balance({user_id: @token_user[:uuid]})
          if response[:success]
            @balance_from_ost = response[:data][response[:data][:result_type]]
            Thread.current[:output] = Result.success({})
          else
            Thread.current[:output] = Result.error('a_s_tum_baui_gb_3', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
          end
        }
      end

      # final response
      #
      def final_response
        Result.success({result_type: 'balance',
                        price_point: @ost_price_point_data,
                        balance: ResponseEntity::TokenUserBalance.format(@token_user, @balance_from_ost)})
      end

    end

  end

end