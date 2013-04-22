class CreateCharacters < ActiveRecord::Migration
  def change
    create_table :characters do |t|
    	t.integer :account_id, :null => false
    	t.integer :piece_id, :null => false
      t.string 	:name, :null => false, :limit => 30
      t.integer :position, :null => false

      t.timestamps
    end
    add_index :characters, :account_id
    add_index :characters, :piece_id
  end
end
