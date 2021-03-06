module CacheManagement

  # Class to cache token user details by token user id.
  class TokenUserById < CacheManagement::Base

    private

    # Fetch from db.
    #
    def fetch_from_db(cache_miss_ids)
      data_to_cache = ::TokenUser.where(id: cache_miss_ids).inject({}) do |data, obj|
        data[obj.id] = obj.formatted_cache_data
        data
      end
      Result.success(data_to_cache)
    end

    # Fetch cache key.
    #
    def get_cache_key(id)
      "token_user_bid_#{id}"
    end

    # Fetch cache expiry (in seconds).
    #
    def get_cache_expiry
      GlobalConstant::Cache.default_ttl
    end

  end

end
