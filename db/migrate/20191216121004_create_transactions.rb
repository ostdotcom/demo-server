class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.column :ost_tx_id, :string, null: false
      t.column :status, :integer, null: false
      t.column :transaction_data, :text, null: false
      t.timestamps
    end
    add_index :transactions, [:ost_tx_id], unique: true, name: 'uk_1'
  end
end
