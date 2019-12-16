class CreateUserTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_transactions do |t|
      t.column :token_user_id, :integer, null: false
      t.column :ost_tx_id, :string, null: false
      t.timestamps
    end
    add_index :user_transactions, [:token_user_id], unique: false, name: 'in_1'
  end
end
