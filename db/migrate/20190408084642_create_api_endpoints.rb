class CreateApiEndpoints < ActiveRecord::Migration[5.2]

  def up
    create_table :api_endpoints do |t|
      t.column :endpoint, :string, null: false
      t.timestamps
    end
    add_index :api_endpoints, [:endpoint], unique: true, name: 'uk_1'

    ApiEndpoint.create(endpoint: 'https://api.ost.com/testnet/v2')
  end

  def down
    drop_table :api_endpoints
  end

end
