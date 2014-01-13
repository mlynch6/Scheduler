class CreatePieces < ActiveRecord::Migration
  def change
    create_table :pieces do |t|
    	t.integer :account_id, :null => false
      t.string :name, :null => false, :limit => 50
      t.string :choreographer, :limit => 50
      t.string :music, :limit => 50
      t.string :composer, :limit => 50
      t.integer :avg_length

      t.timestamps
    end
    add_index :pieces, :account_id
    add_index :pieces, [:account_id, :name, :choreographer], :unique => true
  end
end
