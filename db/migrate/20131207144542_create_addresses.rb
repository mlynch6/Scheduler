class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
			t.belongs_to :addressable, :polymorphic => true, :null => false
			t.string :addr_type, :null => false, :limit => 30
			t.string :addr, :null => false, :limit => 50
			t.string :addr2, :limit => 50
			t.string :city, :null => false, :limit => 50
			t.string :state, :null => false, :limit => 2
			t.string :zipcode, :null => false, :limit => 5
			
      t.timestamps
    end
    add_index :addresses, [:addressable_id, :addressable_type]
  end
end
