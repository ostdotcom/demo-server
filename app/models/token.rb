class Token < ApplicationRecord
  after_commit :flush_cache

  # Format token data for cache
  #
  def formatted_cache_data
    {
      id: id,
      ost_token_id: ost_token_id,
      name: name,
      symbol: symbol,
      decimal: decimal,
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

    webhook_secret_e = nil
    if webhook_secret.present?
      webhook_decrypt_res = lc_to_decrypt.decrypt(webhook_secret)
      webhook_secret_d = webhook_decrypt_res[:data][:plaintext] rescue nil

      if webhook_secret_d.present?
        webhook_encrypt_res = lc_to_encrypt.encrypt(webhook_secret_d)
        webhook_secret_e = webhook_encrypt_res[:data][:ciphertext_blob] rescue nil
      end
    end

    {
      id: id,
      ost_token_id: ost_token_id,
      api_key: api_key,
      api_secret: api_secret_e,
      webhook_secret: webhook_secret_e,
      api_endpoint_id: api_endpoint_id,
      updated_at: updated_at,
      created_at: created_at
    }
  end

  def self.validate_webhook_signature(token_id, data, request_headers)
    token_secure = CacheManagement::TokenSecureById.new([token_id]).fetch()[token_id]
    return false if token_secure.blank? || token_secure[:webhook_secret].blank?

    api_endpoint = ApiEndpoint.id_to_endpoint_map[token_secure[:api_endpoint_id]]
    ost_api_helper = OstApiHelper.new({api_key: token_secure[:api_key],
                                       api_secret: token_secure[:api_secret], api_endpoint: api_endpoint})

    webhook_params = {
      stringified_data: data,
      version: request_headers["HTTP_OST_VERSION"],
      request_timestamp: request_headers["HTTP_OST_TIMESTAMP"],
      signature: request_headers["HTTP_OST_SIGNATURE"],
      webhook_secret: token_secure[:webhook_secret]
    }
    Rails.logger.info "===webhook_params==== #{webhook_params}"
    return ost_api_helper.verify_webhook_signature(webhook_params)
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
