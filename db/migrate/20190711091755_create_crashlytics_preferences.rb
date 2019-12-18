class CreateCrashlyticsPreferences < ActiveRecord::Migration[5.2]

  def up
    create_table :crashlytics_preferences do |t|
      t.column :user_id, :integer, null: false
      t.column :device_address, :string, null: false
      t.column :preference, :tinyint, null: false
      t.timestamps
    end
  end

  def down
    drop_table :crashlytics_preferences
  end

end
