class CreatePieces < ActiveRecord::Migration
  def change
    create_table :pieces do |t|
    	t.integer :account_id, :null => false
      t.string :name, :null => false, :limit => 50
      t.boolean :active, :null => false, :default => true

      t.timestamps
    end
    add_index :pieces, :account_id
    add_index :pieces, [:account_id, :name], :unique => true
  end
end
