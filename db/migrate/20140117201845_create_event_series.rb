class CreateEventSeries < ActiveRecord::Migration
  def change
    create_table :event_series do |t|
      t.string :period, :null => false, :limit => 20
      t.date :start_at, :null => false
      t.date :end_at, :null => false

      t.timestamps
    end
  end
end
