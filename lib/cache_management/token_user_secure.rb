module CacheManagement

  # Class to cache secure token user details by token id.
  class TokenUserSecure < CacheManagement::Base

    # Fetch from cache. In case of cache misses, call fetch_from_db.
    # Over riding the method from base class to store encrypted keys in cache.
    #
    def fetch
      data_cache = super

      data_cache.each do |id, user_data|
        next if user_data.blank?
        # deep dup to not modify the current object
        user_data = user_data.deep_dup
        data_cache[id] = user_data
        lc_to_decrypt = LocalCipher.new(GlobalConstant::Base.local_cipher_key)
        # Decrypt Password
        lc_to_decrypt_password_res = lc_to_decrypt.decrypt(user_data[:password])
        if lc_to_decrypt_password_res[:success]
          user_data[:password] = lc_to_decrypt_password_res[:data][:plaintext]
        else
          data_cache[id] = {}
        end
      end
      data_cache
    end

    private

    # Fetch from db.
    #
    def fetch_from_db(cache_miss_ids)
      data_to_cache = ::TokenUser.where(id: cache_miss_ids).inject({}) do |data, obj|
        data[obj.id] = obj.formatted_secure_cache_data
        data
      end
      Result.success(data_to_cache)
    end

    # Fetch cache key.
    #
    def get_cache_key(id)
      "token_user_secure_#{id}"
    end

    # Fetch cache expiry (in seconds).
    #
    def get_cache_expiry
      GlobalConstant::Cache.default_ttl
    end

  end

end
