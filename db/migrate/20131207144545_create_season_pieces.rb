class CreateSeasonPieces < ActiveRecord::Migration
  def change
    create_table :season_pieces do |t|
      t.integer :season_id, :null => false
      t.integer :piece_id, :null => false

      t.timestamps
    end
    
    add_index :season_pieces, :season_id
    add_index :season_pieces, :piece_id
    add_index :season_pieces, [:season_id, :piece_id], :unique => true
  end
end
