# frozen_string_literal: true
module GlobalConstant

  class Cache

    class << self

      def endpoints
        @endpoints ||= ENV["DEMO_MEMCACHE_ENDPOINTS"].to_s.split(',').map(&:strip)
      end

      def config
        @m_c ||= {
          expires_in: 1.day,
          compress: false,
          down_retry_delay: 5,
          socket_timeout: 1,
          namespace: ENV["DEMO_MEMCACHE_KEY_PREFIX"]
        }
      end

      def default_ttl
        24.hours.to_i
      end

    end

  end

end