class CreateTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :tokens do |t|
      t.column :token_id, :integer, null: false
      t.column :api_endpoint_id, :integer, null: false
      t.column :name, :string, null: false
      t.column :symbol, :string, null: false
      t.column :url_id, :string, null: false
      t.column :api_key, :text, null: false
      t.column :api_secret, :text, null: false #encrypted
      t.column :encryption_salt, :blob, null: false
      t.column :pc_token_holder_uuid, :string, null: false
      t.timestamps
    end
    add_index :tokens, [:url_id], unique: true, name: 'uk_1'
  end
end
