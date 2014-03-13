class CreateEventSeries < ActiveRecord::Migration
  def change
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
