class CreateUserTransactions < ActiveRecord::Migration[5.2]
  def up
    create_table :user_transactions do |t|
      t.column :token_user_id, :bigint, limit:20, null: false
      t.column :transaction_id, :bigint, limit:20, null: false
      t.timestamps
    end
    add_index :user_transactions, [:token_user_id], unique: false, name: 'in_1'

    execute "ALTER TABLE user_transactions AUTO_INCREMENT=1000000;"
  end

  def down
    drop_table :user_transactions
  end
end
