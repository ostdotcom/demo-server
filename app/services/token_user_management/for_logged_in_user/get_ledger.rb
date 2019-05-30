module TokenUserManagement

  module ForLoggedInUser

    class GetLedger

      # Get logged in user detail Constructor
      #
      def initialize(params)
        @token = params[:token]
        @token_id = @token[:id]
        @token_user = params[:token_user]
        @pagination_identifier = params[:pagination_identifier]

        @token_secure = nil
        @api_endpoint = nil
        @ost_api_helper = nil
        @api_response_data = nil
      end

      # Perform action
      #
      def perform
        r = validate_params
        return r unless r[:success]

        r = set_ost_api_helper
        return r unless r[:success]

        r = fetch_ledger_from_ost
        return r unless r[:success]

        r = fetch_user_data_from_db
        return r unless r[:success]

        final_response
      end

      private

      # validate params
      #
      def validate_params
        r = validate_pagination_identifier
        return r unless r[:success]
        Result.success({})
      end

      # validate pagination identifier
      #
      def validate_pagination_identifier
        if @pagination_identifier.blank? || Validator.is_alphanumeric_equal?(@pagination_identifier)
          Result.success({})
        else
          Result.error('a_s_tum_fliu_gl_1', 'INVALID_REQUEST', 'Invalid pagination_identifier')
        end
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
        return Result.error('a_s_tum_fliu_gl_2',
                            'INVALID_REQUEST',
                            'Invalid token') if @token_secure.blank?
        Result.success({})
      end

      # Fetch API Endpoint
      #
      def fetch_api_endpoint
        @api_endpoint = ApiEndpoint.id_to_endpoint_map[@token[:api_endpoint_id]]
        return Result.error('a_s_tum_fliu_gl_3',
                            'INVALID_REQUEST',
                            'Invalid token') if @api_endpoint.blank?
        Result.success({})
      end

      # fetch ledger from OST
      #
      def fetch_ledger_from_ost

        fetch_ledger_params = {user_id: @token_user[:uuid]}
        if @pagination_identifier.present?
          fetch_ledger_params[:pagination_identifier] = @pagination_identifier
        end

        response = @ost_api_helper.fetch_user_transaction_ledger(fetch_ledger_params)
        unless response[:success]
          return Result.error('a_s_tum_fliu_gl_4', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
        end

        # Initialize Response data with OST Response
        @api_response_data = response[:data]

        Result.success({})
      end

      # fetch user data from DB
      #
      def fetch_user_data_from_db

        @api_response_data[:transaction_users] = {}

        uuids_set = Set.new([])
        # Collect user uuid(s) from @api_response_data
        @api_response_data[@api_response_data[:result_type]].each do |transaction|
          transaction[:transfers].each do |transfer|
            uuids_set.add(transfer[:from_user_id]) if transfer[:from_user_id].present?
            uuids_set.add(transfer[:to_user_id]) if transfer[:to_user_id].present?
          end
        end

        uuids_array = uuids_set.to_a
        return Result.success({}) unless uuids_array.any?

        token_user_data_by_uuid = CacheManagement::TokenUserByUuid.new(uuids_array).fetch()

        # collect uuids which were not found in TokenUser
        missing_uuids, uuid_token_user_id_map, token_user_ids = [], {}, []
        uuids_array.each do |uuid|
          if token_user_data_by_uuid[uuid].present?
            uuid_token_user_id_map[uuid] = token_user_data_by_uuid[uuid][:id]
            token_user_ids.push(token_user_data_by_uuid[uuid][:id])
          else
            missing_uuids.push(uuid)
          end
        end

        token_users_data_by_id = CacheManagement::TokenUserById.new(token_user_ids).fetch()

        uuid_token_user_id_map.each do |uuid, token_user_id|
          @api_response_data[:transaction_users][uuid] = ResponseEntity::TokenUser.format(token_users_data_by_id[token_user_id])
        end

        return Result.success({})

      end

      # final response
      #
      def final_response
        Result.success(@api_response_data)
      end

    end

  end

end