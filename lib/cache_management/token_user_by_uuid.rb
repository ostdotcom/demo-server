module CacheManagement

  class TokenUserByUuid < CacheManagement::Base

    private

    # Fetch from db
    #
    def fetch_from_db(cache_miss_uuids)
      data_to_cache = ::TokenUser.where(uuid: cache_miss_uuids).select([:id, :uuid]).inject({}) do |data, obj|
        data[obj.uuid] = {
          id: obj.id
        }
        data
      end
      Result.success(data_to_cache)
    end

    # Fetch cache key
    #
    def get_cache_key(uuid)
      "token_user_buuid_#{uuid}"
    end

    # Fetch cache expiry (in seconds)
    #
    def get_cache_expiry
      GlobalConstant::Cache.default_ttl
    end

  end

end