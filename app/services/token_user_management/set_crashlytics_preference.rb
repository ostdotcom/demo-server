module TokenUserManagement
  class SetCrashlyticsPreference

    # Set user's crashlytics preference
    def initialize(params)
      @app_user_id = params[:app_user_id]
      @preference = params[:preference]
    end

    # Action on settings user's crashlytics preference
    #
    # @preference = 1, when user opts In for sending crash reports to crashlytics.
    # @preference = 0, when user opts Out for sending crash reports to crashlytics.
    #
    def perform

      r = validate_token_user_id
      return r unless r[:success]

      return Result.error('a_s_tum_scp_1', 'INVALID_REQUEST',
                          'Invalid preference') if(['1', '0'].exclude?(@preference.to_s))

      CrashlyticsPreference.create(user_id: @app_user_id, preference: @preference)

      Result.success({})

    end

    private

    # validate token user id
    #
    def validate_token_user_id
      return Result.error('a_s_tum_scp_2', 'INVALID_REQUEST', 'Invalid token user id') unless Validator.is_numeric?(@app_user_id)
      @app_user_id = @app_user_id.to_i
      Result.success({})
    end

  end
end