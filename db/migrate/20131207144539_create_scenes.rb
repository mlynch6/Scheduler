class CreateScenes < ActiveRecord::Migration
  def change
    create_table :scenes do |t|
    	t.integer :account_id, :null => false
    	t.integer :piece_id, :null => false
      t.string 	:name, :null => false, :limit => 100
      t.integer :position, :null => false
      t.string 	:track, :limit => 20

      t.timestamps
    end
    add_index :scenes, :account_id
    add_index :scenes, :piece_id
  end
end
