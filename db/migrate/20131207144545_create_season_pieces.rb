class CreateSeasonPieces < ActiveRecord::Migration
	def change
		create_table :season_pieces do |t|
			t.integer :account_id, :null => false
			t.integer :season_id, :null => false
			t.integer :piece_id, :null => false
			t.boolean :published, :null => false, :default => false
			t.datetime :published_at

			t.timestamps
		end
		add_index :season_pieces, :account_id
		add_index :season_pieces, :season_id
		add_index :season_pieces, :piece_id
		add_index :season_pieces, [:season_id, :piece_id], :unique => true
	end
end
