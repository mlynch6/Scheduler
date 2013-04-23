class CreateAppearances < ActiveRecord::Migration
  def change
    create_table :appearances do |t|
    	t.integer :scene_id, :null => false
      t.integer :character_id, :null => false

      t.timestamps
    end
    add_index :appearances, :scene_id
    add_index :appearances, :character_id
    add_index :appearances, [:scene_id, :character_id], :unique => true
  end
end
