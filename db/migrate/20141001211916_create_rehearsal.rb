class CreateRehearsal < ActiveRecord::Migration
  def change
    create_table :rehearsals do |t|
      t.integer :account_id, :null => false
      t.integer :season_id, :null => false
      t.string :title, :null => false, :limit => 30
			t.integer :piece_id, :null => false
			t.integer :scene_id
      t.text :comment

      t.timestamps
    end
    add_index :rehearsals, :account_id
    add_index :rehearsals, :season_id
		add_index :rehearsals, :piece_id
		add_index :rehearsals, :scene_id
  end
end
