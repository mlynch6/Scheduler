class AddDemoFieldsToAgmaContract < ActiveRecord::Migration
  def change
    add_column :agma_contracts, :demo_max_duration, :integer
		add_column :agma_contracts, :demo_max_num_per_day, :integer
  end
end
