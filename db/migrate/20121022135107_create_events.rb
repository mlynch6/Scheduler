class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, :null => false, :limit => 30
      t.string :event_type, :null => false, :limit => 20
      t.integer :location_id, :null => false
      t.datetime :start_at, :null => false
      t.datetime :end_at, :null => false
      t.integer :piece_id

      t.timestamps
    end
    add_index :events, :location_id
    add_index :events, :piece_id
  end
end
