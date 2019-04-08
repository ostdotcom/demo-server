module CacheManagement

  class TokenSecure < CacheManagement::Base

    # Fetch
    #
    def fetch
      data_cache = super
      data_cache.each do |token_id, token_data|
        next if token_data.blank?
        lc_to_decrypt = LocalCipher.new(GlobalConstant::Base.local_cipher_key)
        lc_to_decrypt_res = lc_to_decrypt.decrypt(token_data[:api_secret])
        if lc_to_decrypt_res[:success]
          token_data[:api_secret] = lc_to_decrypt_res.data[:plaintext]
        else
          data_cache[token_id] = {}
        end
      end
      data_cache
    end

    private

    # Fetch from db
    #
    def fetch_from_db(cache_miss_ids)
      data_to_cache = ::Token.where(id: cache_miss_ids).inject({}) do |data, obj|
        data[obj.id] = obj.formatted_secure_cache_data
        data
      end
      Result.success(data_to_cache)
    end

    # Fetch cache key
    #
    def get_cache_key(id)
      "#{GlobalConstant::Cache.key_prefix}_token_secure_#{id}"
    end

    # Fetch cache expiry (in seconds)
    #
    def get_cache_expiry
      GlobalConstant::Cache.default_ttl
    end

  end

end