class CreateAgmaProfiles < ActiveRecord::Migration
  def change
    create_table :agma_profiles do |t|
    	t.integer :account_id, :null => false
    	t.time :rehearsal_start, :null => false
    	t.time :rehearsal_end, :null => false
      t.integer :rehearsal_max_hrs_per_week, :null => false
      t.integer :rehearsal_max_hrs_per_day, :null => false
      t.integer :rehearsal_increment_min, :null => false

      t.timestamps
    end
    add_index :agma_profiles, :account_id, :unique => true
  end
end
