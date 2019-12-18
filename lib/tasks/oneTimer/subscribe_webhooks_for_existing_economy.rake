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

      api_endpoint = ApiEndpoint.where(id: api_endpoint_id).first.endpoint

      @ost_token_id_to_tokens_hash[ost_token_id] = {
        api_endpoint: api_endpoint,
        api_key: api_key,
        api_secret: api_secret
      }
    end

    @ost_token_id_to_tokens_hash.each do |token_id, data|
      @ost_api_helper = OstApiHelper.new({
                                           api_key: data[:api_key],
                                           api_secret: data[:api_secret],
                                           api_endpoint: data[:api_endpoint]
                                         })
      @ost_api_helper.create_webhooks({
                                        topics: GlobalConstant::OstEvents.webhook_topics,
                                        url: GlobalConstant::OstEvents.webhook_subscription_endpoint})
    end

    puts "Rake task completed successfully."

  end

end
