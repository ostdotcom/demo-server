class Token < ApplicationRecord
  after_commit :flush_cache

  # Format token data for cache
  #
  def formated_cache_data
    {
      id: id,
      ost_token_id: ost_token_id,
      name: name,
      symbol: symbol,
      conversion_factor: conversion_factor,
      pc_token_holder_uuid: pc_token_holder_uuid,
      url_id: url_id,
      api_endpoint_id: api_endpoint_id,
      chain_id: chain_id,
      updated_at: updated_at,
      created_at: created_at
    }
  end

  # Format token secure data for cache
  #
  def formatted_secure_cache_data
    decrypt_salt_rsp = Kms.new.decrypt(encryption_salt)
    return {} unless decrypt_salt_rsp[:success]
    encryption_salt_d = decrypt_salt_rsp[:data][:plaintext]

    lc_to_decrypt = LocalCipher.new(encryption_salt_d)
    lc_to_decrypt_res = lc_to_decrypt.decrypt(api_secret)
    return {} unless lc_to_decrypt_res[:success]
    api_secret_d = lc_to_decrypt_res[:data][:plaintext]

    lc_to_encrypt = LocalCipher.new(GlobalConstant::Base.local_cipher_key)
    lc_to_encrypt_res = lc_to_encrypt.encrypt(api_secret_d)
    return {} unless lc_to_encrypt_res[:success]
    api_secret_e = lc_to_encrypt_res[:data][:ciphertext_blob]

    {
      id: id,
      ost_token_id: ost_token_id,
      api_key: api_key,
      api_secret: api_secret_e,
      api_endpoint_id: api_endpoint_id,
      updated_at: updated_at,
      created_at: created_at
    }
  end

  private

  # Flush cache
  #
  def flush_cache
    CacheManagement::TokenById.new([id]).clear
    CacheManagement::TokenSecureById.new([id]).clear
    CacheManagement::TokenByOstDetail.new([ost_token_id], {url_id: url_id}).clear
  end

end
