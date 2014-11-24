class ChangeCostumeFittingColumnOnAgmaContract < ActiveRecord::Migration
  def up
		change_column :agma_contracts, :costume_increment_min, :integer, :null => true
  end

  def down
		change_column :agma_contracts, :costume_increment_min, :integer, :null => false
  end
end
