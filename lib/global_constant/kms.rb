# frozen_string_literal: true
module GlobalConstant

  class Kms

    class << self

      def access_key
        @access_key = ENV["DEMO_AWS_KMS_ACCESS_KEY"].to_s
      end

      def secret
        @secret = ENV["DEMO_AWS_KMS_SECRET_KEY"].to_s
      end

      def region
        @region = ENV["DEMO_AWS_KMS_REGION"].to_s
      end

      def key_id
        @key_id = ENV["DEMO_AWS_KMS_KEY_ID"].to_s
      end

    end

  end

end