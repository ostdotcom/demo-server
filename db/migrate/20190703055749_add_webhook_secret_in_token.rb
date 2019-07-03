class AddWebhookSecretInToken < ActiveRecord::Migration[5.2]
  def change
    add_column :tokens, :webhook_secret, :text, :after => :api_secret, :null => true #encrypted
  end
end
