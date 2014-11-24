class ChangeReearsalColumnsOnAgmaContract < ActiveRecord::Migration
  def up
		change_column :agma_contracts, :rehearsal_start_min, :integer, :null => true
		change_column :agma_contracts, :rehearsal_end_min, :integer, :null => true
		change_column :agma_contracts, :rehearsal_max_hrs_per_week, :integer, :null => true
		change_column :agma_contracts, :rehearsal_max_hrs_per_day, :integer, :null => true
		change_column :agma_contracts, :rehearsal_increment_min, :integer, :null => true
  end

  def down
		change_column :agma_contracts, :rehearsal_start_min, :integer, :null => false
		change_column :agma_contracts, :rehearsal_end_min, :integer, :null => false
		change_column :agma_contracts, :rehearsal_max_hrs_per_week, :integer, :null => false
		change_column :agma_contracts, :rehearsal_max_hrs_per_day, :integer, :null => false
		change_column :agma_contracts, :rehearsal_increment_min, :integer, :null => false
  end
end
