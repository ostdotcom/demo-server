class AddIndexToTokenUser < ActiveRecord::Migration[5.2]

  def change
    add_index :token_users, [:uuid], unique: true, name: 'uk_2'
  end

end
