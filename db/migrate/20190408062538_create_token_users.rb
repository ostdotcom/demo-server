class CreateTokenUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :token_users do |t|
      t.column :token_id, :integer, null: false
      t.column :username, :string, null: false
      t.column :password, :text, null: false #encrypted
      t.column :encryption_salt, :blob, null: false
      t.column :uuid, :string, null: true
      t.timestamps
    end
    add_index :token_users, [:token_id, :username], unique: true, name: 'uk_1'
  end
end
