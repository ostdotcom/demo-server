# frozen_string_literal: true
module GlobalConstant

  class Base

    class << self

      def environment
        @environment ||= Rails.env
      end

      def local_cipher_key
        @local_cipher_key ||= ENV['DEMO_LOCAL_CIPHER_KEY']
      end

      def kit_secret_key
        @kit_secret_key ||= ENV['KIT_SECRET_KEY']
      end

      def demo_endpoint
        @demo_endpoint ||= ENV['DEMO_API_ENDPOINT']
      end

    end

  end

end
