namespace :one_timers do

  # rake RAILS_ENV=development one_timers:subscribe_webhooks_for_existing_economy

  task :subscribe_webhooks_for_existing_economy => :environment do

    @ost_token_id_to_tokens_hash = {}
    Token.all.each do |token|
      token_id = token.id
      ost_token_id = token.ost_token_id
      api_endpoint_id = token.api_endpoint_id
      api_key = token.api_key
      api_secret = CacheManagement::TokenSecureById.new([token_id]).fetch()[token_id][:api_secret]

      @ost_token_id_to_tokens_hash[ost_token_id] = {
        api_endpoint_id: api_endpoint_id,
        api_key: api_key,
        api_secret: api_secret
      }
    end

    puts @ost_token_id_to_tokens_hash

  end

end
