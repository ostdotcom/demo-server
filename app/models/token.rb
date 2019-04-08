class Token < ApplicationRecord
  after_commit :flush_cache

  # Format token data for cache
  #
  def formated_cache_data
    {
      id: id,
      token_id: token_id,
      name: name,
      symbol: symbol,
      pc_token_holder_uuid: pc_token_holder_uuid,
      url_id: url_id,
      api_endpoint_id: api_endpoint_id
    }
  end

  # Format token secure data for cache
  #
  def formatted_secure_cache_data
    decrypt_salt_rsp = Kms.new.decrypt(encryption_salt)
    return {} unless decrypt_salt_rsp[:success]
    encryption_salt_d = decrypt_salt_rsp.data[:plaintext]

    lc_to_decrypt = LocalCipher.new(encryption_salt_d)
    lc_to_decrypt_res = lc_to_decrypt.decrypt(api_secret)
    return {} unless lc_to_decrypt_res[:success]
    api_secret_d = lc_to_decrypt_res.data[:plaintext]

    lc_to_encrypt = LocalCipher.new(GlobalConstant::Base.local_cipher_key)
    lc_to_encrypt_res = lc_to_encrypt.encrypt(api_secret_d)
    return {} unless lc_to_encrypt_res[:success]
    api_secret_e = lc_to_encrypt_res.data[:ciphertext_blob]

    {
      id: id,
      token_id: token_id,
      api_key: api_key,
      api_secret: api_secret_e,
      api_endpoint_id: api_endpoint_id
    }
  end

  private

  # Flush cache
  #
  def flush_cache
    CacheManagement::Token.new([id]).clear
    CacheManagement::TokenSecure.new([id]).clear
  end

end
