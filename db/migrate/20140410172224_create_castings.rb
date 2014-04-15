class CreateCastings < ActiveRecord::Migration
	def change
		create_table :castings do |t|
			t.integer :account_id, :null => false
			t.integer :cast_id, :null => false
			t.integer :character_id, :null => false
			t.integer :person_id

			t.timestamps
		end
		add_index :castings, :account_id
		add_index :castings, :cast_id
		add_index :castings, :character_id
		add_index :castings, :person_id
		add_index :castings, [:cast_id, :character_id], :unique => true
	end
end
