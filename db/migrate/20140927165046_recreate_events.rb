class RecreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
    	t.integer :account_id, :null => false
			t.belongs_to :schedulable, :polymorphic => true, :null => false
      t.string :title, :null => false, :limit => 30
      t.integer :location_id
      t.datetime :start_at, :null => false
      t.datetime :end_at, :null => false
			t.text :comment

      t.timestamps
    end
    add_index :events, :account_id
    add_index :events, :location_id
		add_index :events, [:schedulable_id, :schedulable_type]
  end
end
