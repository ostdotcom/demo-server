class AddColumnsInTokenUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :token_users, :ost_activation_ts, :integer, :after => :ost_user_status, :null => true
    add_column :token_users, :first_transaction_ts, :integer, :after => :ost_activation_ts, :null => true
  end
end
