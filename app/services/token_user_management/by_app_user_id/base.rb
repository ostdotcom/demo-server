module TokenUserManagement

  module ByAppUserId

    class Base

      # By App user id Base Constructor
      #
      def initialize(params)
        @token = params[:token]
        @token_id = @token[:id]
        @app_user_id = params[:app_user_id]

        @token_user = nil
        @token_secure = nil
        @api_endpoint = nil
        @ost_api_helper = nil
      end

      private

      # validate params
      #
      def validate_params
        r = validate_token_user_id
        return r unless r[:success]

        Result.success({})
      end

      # validate token user id
      #
      def validate_token_user_id
        return Result.error('a_s_tum_baui_b_1', 'INVALID_REQUEST', 'Invalid token user id') unless Validator.is_numeric?(@app_user_id)
        @app_user_id = @app_user_id.to_i
        Result.success({})
      end

      # Get user detail
      #
      def get_user_detail

        @token_user = CacheManagement::TokenUser.new([@app_user_id]).fetch()[@app_user_id]

        if @token_user.blank? || @token_user[:token_id] != @token[:id]
          return Result.error('a_s_tum_baui_b_2', 'INVALID_REQUEST', 'Invalid token user id')
        end

        Result.success({})
      end

      # Set OST API Helper Object
      #
      def set_ost_api_helper
        r = fetch_token_secure
        return r unless r[:success]

        r = fetch_api_endpoint
        return r unless r[:success]

        @ost_api_helper = OstApiHelper.new({api_key: @token_secure[:api_key],
                                            api_secret: @token_secure[:api_secret], api_endpoint: @api_endpoint})
        Result.success({})
      end

      # Fetch Token Secure data
      #
      def fetch_token_secure
        @token_secure = CacheManagement::TokenSecureById.new([@token_id]).fetch()[@token_id]
        return Result.error('a_s_tum_baui_b_3',
                            'INVALID_REQUEST',
                            'Invalid token') if @token_secure.blank?
        Result.success({})
      end

      # Fetch API Endpoint
      #
      def fetch_api_endpoint
        @api_endpoint = ApiEndpoint.id_to_endpoint_map[@token[:api_endpoint_id]]
        return Result.error('a_s_tum_baui_b_4',
                            'INVALID_REQUEST',
                            'Invalid token') if @api_endpoint.blank?
        Result.success({})
      end

    end

  end

end