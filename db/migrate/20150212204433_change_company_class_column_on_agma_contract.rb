class ChangeCompanyClassColumnOnAgmaContract < ActiveRecord::Migration
  def up
		change_column :agma_contracts, :class_break_min, :integer, :null => true
  end

  def down
		change_column :agma_contracts, :class_break_min, :integer, :null => false
  end
end
