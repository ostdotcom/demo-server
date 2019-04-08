# frozen_string_literal: true
module GlobalConstant

  class Base

    class << self

      def environment
        Rails.env
      end

      def ost_api_endpoint
        @ost_api_endpoint ||= ENV["DEMO_OST_API_ENDPOINT"]
      end

      def memcache_servers
        @memcache_servers ||= ENV["DEMO_MEMCACHE_SERVERS"]
      end

      def memcache_key_prefix
        @memcache_key_prefix ||= ENV["DEMO_MEMCACHE_KEY_PREFIX"]
      end

    end

  end

end
