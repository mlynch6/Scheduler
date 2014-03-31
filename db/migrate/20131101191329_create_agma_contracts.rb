class CreateAgmaContracts < ActiveRecord::Migration
	def change
		create_table :agma_contracts do |t|
			t.integer :account_id, :null => false
			t.integer :rehearsal_start_min, :null => false
			t.integer :rehearsal_end_min, :null => false
			t.integer :rehearsal_max_hrs_per_week, :null => false
			t.integer :rehearsal_max_hrs_per_day, :null => false
			t.integer :rehearsal_increment_min, :null => false
			t.integer :class_break_min, :null => false
			t.integer :rehearsal_break_min_per_hr, :null => false
			t.integer :costume_increment_min, :null => false

			t.timestamps
		end
		add_index :agma_contracts, :account_id, :unique => true
	end
end
