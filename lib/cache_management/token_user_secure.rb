module CacheManagement

  class TokenUserSecure < CacheManagement::Base

    # Fetch
    #
    def fetch
      data_cache = super
      data_cache.each do |id, user_data|
        next if user_data.blank?
        lc_to_decrypt = LocalCipher.new(GlobalConstant::Base.local_cipher_key)
        # Decrypt Password
        lc_to_decrypt_password_res = lc_to_decrypt.decrypt(user_data[:password])
        # Decrypt User Pin Salt
        lc_to_decrypt_user_pin_salt_res = lc_to_decrypt.decrypt(user_data[:user_pin_salt])

        if lc_to_decrypt_password_res[:success] && lc_to_decrypt_user_pin_salt_res[:success]
          user_data[:password] = lc_to_decrypt_password_res[:data][:plaintext]
          user_data[:user_pin_salt] = lc_to_decrypt_user_pin_salt_res[:data][:plaintext]
        else
          data_cache[id] = {}
        end
      end
      data_cache
    end

    private

    # Fetch from db
    #
    def fetch_from_db(cache_miss_ids)
      data_to_cache = ::TokenUser.where(id: cache_miss_ids).inject({}) do |data, obj|
        data[obj.id] = obj.formatted_secure_cache_data
        data
      end
      Result.success(data_to_cache)
    end

    # Fetch cache key
    #
    def get_cache_key(id)
      "#{GlobalConstant::Cache.key_prefix}_token_user_secure_#{id}"
    end

    # Fetch cache expiry (in seconds)
    #
    def get_cache_expiry
      GlobalConstant::Cache.default_ttl
    end

  end

end