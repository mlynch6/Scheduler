class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
			t.belongs_to :phoneable, :polymorphic => true, :null => false
			t.string :phone_type, :null => false, :limit => 20
			t.string :phone_num, :null => false, :limit => 13
			t.boolean :primary, :null => false, :default => false
			
      t.timestamps
    end
    add_index :phones, [:phoneable_id, :phoneable_type]
  end
end
