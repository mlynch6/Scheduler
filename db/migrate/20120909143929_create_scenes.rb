class CreateScenes < ActiveRecord::Migration
  def change
    create_table :scenes do |t|
      t.string :name, :null => false, :limit => 100
      t.integer :order_num, :null => false
      t.integer :piece_id, :null => false

      t.timestamps
    end
    add_index :scenes, :piece_id
  end
end
