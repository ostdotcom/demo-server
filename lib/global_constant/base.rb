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

    end

  end

end
