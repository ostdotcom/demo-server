module CacheManagement

  # Class to cache secure token details by token id.
  class TokenSecureById < CacheManagement::Base

    # Fetch from cache. In case of cache misses, call fetch_from_db.
    # Over riding the method from base class to store encrypted keys in cache.
    #
    def fetch
      data_cache = super

      data_cache.each do |id, token_data|
        next if token_data.blank?
        # Deep dup to not modify the current object.
        token_data = token_data.deep_dup
        data_cache[id] = token_data
        lc_to_decrypt = LocalCipher.new(GlobalConstant::Base.local_cipher_key)
        lc_to_decrypt_res = lc_to_decrypt.decrypt(token_data[:api_secret])
        if lc_to_decrypt_res[:success]
          token_data[:api_secret] = lc_to_decrypt_res[:data][:plaintext]
          if token_data[:webhook_secret].present?
            webhook_decrypt_res = lc_to_decrypt.decrypt(token_data[:webhook_secret])
            token_data[:webhook_secret] = webhook_decrypt_res[:data][:plaintext] rescue nil
          end
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
      data_to_cache = ::Token.where(id: cache_miss_ids).inject({}) do |data, obj|
        data[obj.id] = obj.formatted_secure_cache_data
        data
      end
      Result.success(data_to_cache)
    end

    # Fetch cache key.
    #
    def get_cache_key(id)
      "token_secure_by_id_#{id}"
    end

    # Fetch cache expiry (in seconds).
    #
    def get_cache_expiry
      GlobalConstant::Cache.default_ttl
    end

  end

end
