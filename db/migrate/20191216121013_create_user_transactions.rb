class CreateUserTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_transactions do |t|
      t.column :token_user_id, :bigint, limit:20, null: false
      t.column :transaction_id, :bigint, limit:20, null: false
      t.column :transaction_ts, :integer, null: false
      t.timestamps
    end
    add_index :user_transactions, [:token_user_id, :transaction_ts], unique: false, name: 'in_1'
  end
end
