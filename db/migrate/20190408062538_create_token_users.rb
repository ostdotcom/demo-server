class CreateTokenUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :token_users do |t|
      t.column :fullname, :string, null: false
      t.column :username, :string, null: false
      t.column :password, :text, null: false #encrypted
      t.column :user_pin_salt, :text, null: false #encrypted
      t.column :encryption_salt, :blob, null: false
      t.column :cookie_salt, :string, null: false
      t.column :token_id, :integer, null: false
      t.column :ost_token_id, :integer, null: false
      t.column :uuid, :string, null: true
      t.column :token_holder_address, :string, null: true
      t.column :device_manager_address, :string, null: true
      t.column :recovery_address, :string, null: true
      t.column :ost_user_status, :string, null: true
      t.timestamps
    end
    add_index :token_users, [:token_id, :username], unique: true, name: 'uk_1'
    add_index :token_users, [:token_id, :fullname], unique: false, name: 'token_id_fullname'
  end
end
