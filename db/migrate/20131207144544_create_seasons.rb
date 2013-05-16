class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.integer :account_id, :null => false
      t.string :name, :null => false, :limit => 30
      t.date :start_dt, :null => false
      t.date :end_dt, :null => false

      t.timestamps
    end
    add_index :seasons, :account_id
  end
end
