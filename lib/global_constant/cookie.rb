# frozen_string_literal: true
module GlobalConstant

  class Cookie

    class << self

      def user_authentication_cookie
        @user_authentication_cookie ||= 'ost_demo_auth'
      end

    end

  end

end