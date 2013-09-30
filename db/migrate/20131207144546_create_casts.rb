class CreateCasts < ActiveRecord::Migration
  def change
    create_table :casts do |t|
      t.integer :season_piece_id, :null => false
      t.string :name, :null => false, :limit => 20

      t.timestamps
    end
    add_index :casts, [:season_piece_id, :name], :unique => true
  end
end
