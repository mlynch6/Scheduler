class CreateEventSeries < ActiveRecord::Migration
  def change
    create_table :event_series do |t|
      t.string :period, :null => false, :limit => 20
      t.date :start_date, :null => false
      t.date :end_date, :null => false

      t.timestamps
    end
  end
end
