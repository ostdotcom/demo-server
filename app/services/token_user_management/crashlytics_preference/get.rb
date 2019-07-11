module TokenUserManagement
  module CrashlyticsPreference
    class Get

      # Set user's crashlytics preference
      def initialize(params)
        @app_user_id = params[:app_user_id]
        @device_address = params[:device_address]
      end

      # Action on settings user's crashlytics preference
      #
      def perform

        r = validate_token_user_id
        return r unless r[:success]

        r = validate_device_address
        return r unless r[:success]

        row = ::CrashlyticsPreference.select('*').
            where(user_id: @app_user_id, device_address: @device_address).
            order('id DESC').limit(1)

        resp = {app_user_id: @app_user_id, device_address: @device_address}
        resp.merge!(preference: row[0].preference) if row.present?

        Result.success(resp)

      end

      private

      # validate token user id
      #
      def validate_token_user_id
        return Result.error('a_s_tum_scp_2', 'INVALID_REQUEST', 'Invalid token user id') unless Validator.is_numeric?(@app_user_id)
        @app_user_id = @app_user_id.to_i
        Result.success({})
      end

      # validate device address
      #
      def validate_device_address
        return Result.error('a_s_tum_scp_3', 'INVALID_REQUEST', 'Invalid device address') unless Validator.is_ethereum_address?(@device_address)
        Result.success({})
      end
    end

  end
end