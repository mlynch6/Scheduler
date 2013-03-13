class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
    	t.integer :account_id, :null => false
      t.string :name, :null => false, :limit => 50
      t.boolean :active, :null => false, :default => true

      t.timestamps
    end
    add_index :locations, :account_id
    add_index :locations, [:account_id, :name], :unique => true
  end
end
