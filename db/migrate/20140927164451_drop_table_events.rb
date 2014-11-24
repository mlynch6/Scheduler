class DropTableEvents < ActiveRecord::Migration
  def up
		drop_table :events
		drop_table :event_series
  end

  def down
    create_table :events do |t|
    	t.integer :account_id, :null => false
      t.string :title, :null => false, :limit => 30
      t.string :type, :null => false, :limit => 20, :default => 'Event'
      t.integer :location_id, :null => false
      t.datetime :start_at, :null => false
      t.datetime :end_at, :null => false
      t.integer :piece_id
      t.integer :event_series_id

      t.timestamps
    end
    add_index :events, :account_id
    add_index :events, :location_id
    add_index :events, :piece_id
    add_index :events, :event_series_id
		
    create_table :event_series do |t|
    	t.integer :account_id, :null => false
      t.string :period, :null => false, :limit => 20
      t.date :start_date, :null => false
      t.date :end_date, :null => false

      t.timestamps
    end
    add_index :event_series, :account_id
  end
end
