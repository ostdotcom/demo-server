class TokenUser < ApplicationRecord
  after_commit :flush_cache

  # Verify cookie
  #
  def self.verify_cookie(cookie_value)
    s_cookie_value = cookie_value.to_s.split(':')
    token_user_id = s_cookie_value[0].to_i
    ctime = s_cookie_value[1].to_i
    cookie_token = s_cookie_value[2]
    return nil if token_user_id <= 0

    token_user_secure_cache = CacheManagement::TokenUserSecure.new([token_user_id]).fetch()[token_user_id]
    return nil if token_user_secure_cache.blank?

    if self.get_cookie_token(token_user_secure_cache, ctime) == cookie_token
      return CacheManagement::TokenUser.new([token_user_id]).fetch()[token_user_id]
    else
      return nil
    end
  end

  # Get login cookie value
  #
  def self.get_cookie_value(token_user_secure_cache)
    ctime = Time.now.to_i
    return "#{token_user_secure_cache[:id]}:#{ctime}:#{self.get_cookie_token(token_user_secure_cache, ctime)}"
  end

  # Get cookie token
  #
  def self.get_cookie_token(token_user_secure_cache, ctime)
    string_to_sign = "#{token_user_secure_cache[:id]}:#{token_user_secure_cache[:token_id]}:#{token_user_secure_cache[:username]}:#{token_user_secure_cache[:cookie_salt]}:#{ctime}:#{token_user_secure_cache[:created_at]}"
    key = "#{token_user_secure_cache[:password]}:#{GlobalConstant::Base.local_cipher_key}"
    OpenSSL::HMAC.hexdigest("SHA256", key, string_to_sign)
  end

  # Format token data for cache
  #
  def formated_cache_data
    {
      id: id,
      token_id: token_id,
      uuid: uuid,
      token_holder_address: token_holder_address,
      device_manager_address: device_manager_address,
      recovery_address: recovery_address
    }
  end

  # Format token secure data for cache
  #
  def formatted_secure_cache_data
    decrypt_salt_rsp = Kms.new.decrypt(encryption_salt)
    return {} unless decrypt_salt_rsp[:success]
    encryption_salt_d = decrypt_salt_rsp.data[:plaintext]

    lc_to_decrypt = LocalCipher.new(encryption_salt_d)
    lc_to_decrypt_res = lc_to_decrypt.decrypt(password)
    return {} unless lc_to_decrypt_res[:success]
    password_d = lc_to_decrypt_res.data[:plaintext]

    lc_to_encrypt = LocalCipher.new(GlobalConstant::Base.local_cipher_key)
    lc_to_encrypt_res = lc_to_encrypt.encrypt(password_d)
    return {} unless lc_to_encrypt_res[:success]
    password_e = lc_to_encrypt_res.data[:ciphertext_blob]

    {
      id: id,
      token_id: token_id,
      username: username,
      password: password_e,
      cookie_salt: cookie_salt,
      created_at: created_at
    }
  end

  private

  # Flush cache
  #
  def flush_cache
    CacheManagement::TokenUser.new([id]).clear
    CacheManagement::TokenUserSecure.new([id]).clear
  end
end
