class CreateOstEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :ost_events do |t|
      t.column :event_id, :string, null: false
      t.column :status, :integer, null: false
      t.column :event_data, :text, null: false
      t.timestamps
    end
    add_index :ost_events, [:event_id], unique: true, name: 'uk_1'
  end
end
