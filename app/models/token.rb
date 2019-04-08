class Token < ApplicationRecord
  after_commit :flush_cache

  # Flush cache
  #
  def flush_cache
    CacheManagement::Token.new([id]).clear
    CacheManagement::TokenSecure.new([id]).clear
  end

  # Format token data for cache
  #
  def formated_cache_data
    {
      id: id,
      url_id: url_id,
      token_id: token_id,
      name: name,
      symbol: symbol,
      pc_token_holder_uuid: pc_token_holder_uuid
    }
  end

  # Format token secure data for cache
  #
  def formatted_secure_cache_data
    {
      id: id,
      url_id: url_id,
      token_id: token_id,
      api_key: api_key,
      api_secret: api_secret,
      encryption_salt: encryption_salt
    }
  end
end
