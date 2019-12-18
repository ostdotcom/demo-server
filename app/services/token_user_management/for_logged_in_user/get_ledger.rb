module TokenUserManagement

  module ForLoggedInUser

    class GetLedger

      # Get logged in user detail Constructor
      #
      def initialize(params)
        @token = params[:token]
        @token_id = @token[:id]
        @token_user = params[:token_user]
        Rails.logger.info "-----params[:pagination_identifier]--1--------------#{params[:pagination_identifier]}"
        @pagination_identifier = Oj.load(params[:pagination_identifier], {symbol_keys: true}) rescue nil
        Rails.logger.info "-----@pagination_identifier--2--------------#{@pagination_identifier}"

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

        r = fetch_transaction_ids_list
        return r unless r[:success]

        r = get_transactions
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
        if @pagination_identifier.blank? || Validator.is_integer?(@pagination_identifier[:last_user_transaction_id])
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

      # fetch paginated transaction_ids
      #
      def fetch_transaction_ids_list
        user_transaction_id = @pagination_identifier[:last_user_transaction_id] if @pagination_identifier.present?

        user_transactions_obj = UserTransaction.where(token_user_id: @token_user[:id])

        Rails.logger.info "-----@user_transaction_id--------------#{user_transaction_id}------#{user_transaction_id.present?}-"
        user_transactions_obj = user_transactions_obj.where(['id < ?', user_transaction_id]) if user_transaction_id.present?

        user_transactions = user_transactions_obj.limit(10).order('id DESC').all

        @transaction_ids, @token_user_ids = [], []
        if user_transactions.present?
          last_user_transaction_id= nil

          user_transactions.each {|ut|
            last_user_transaction_id = ut.id
            @transaction_ids << ut.transaction_id
          }
          @pagination_identifier = {last_user_transaction_id: last_user_transaction_id}

          @token_user_ids = UserTransaction.where(transaction_id: @transaction_ids).map {|all_ut| all_ut.token_user_id}
        else
          @pagination_identifier = nil
        end

        Result.success({})
      end

      def get_transactions

        tx_query_resp = ::Transaction.where(id: @transaction_ids).inject({}) do |data, obj|
          data[obj.id] = obj.formatted_cache_data
          data
        end

        @transactions = @transaction_ids.map {|tx_id| tx_query_resp[tx_id][:transaction_data ]}

        tx_response = {
          result_type: 'transactions',
          transactions: @transactions,
          meta: {next_page_payload:{}, total_no: @transactions.length}
        }

        if @pagination_identifier
          tx_response[:meta][:next_page_payload][:pagination_identifier] = @pagination_identifier
        end

        # Initialize Response data with OST Response
        @api_response_data = tx_response

        Rails.logger.info "======@api_response_data===111111=== #{@api_response_data.to_json}"

        Result.success({})

      end

      # fetch user data from DB
      #
      def fetch_user_data_from_db

        @api_response_data[:transaction_users] = {}

        token_users_data_by_id = CacheManagement::TokenUserById.new(@token_user_ids.uniq).fetch()

        token_users_data_by_id.each do |token_user_id, token_user_data|
          @api_response_data[:transaction_users][token_user_data[:uuid]] = ResponseEntity::TokenUser.format(token_user_data)
        end

        Rails.logger.info "======@api_response_data===2222222222=== #{@api_response_data.to_json}"

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
