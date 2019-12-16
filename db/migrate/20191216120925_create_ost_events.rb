class CreateOstEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :ost_events do |t|

      t.timestamps
    end
  end
end
