module CacheManagement

  class TokenUser < CacheManagement::Base

    private

    # Fetch from db
    #
    def fetch_from_db(cache_miss_ids)
      data_to_cache = ::TokenUser.where(id: cache_miss_ids).inject({}) do |data, obj|
        data[obj.id] = obj.formated_cache_data
        data
      end
      Result.success(data_to_cache)
    end

    # Fetch cache key
    #
    def get_cache_key(id)
      "#{GlobalConstant::Cache.key_prefix}_token_user_#{id}"
    end

    # Fetch cache expiry (in seconds)
    #
    def get_cache_expiry
      GlobalConstant::Cache.default_ttl
    end

  end

end