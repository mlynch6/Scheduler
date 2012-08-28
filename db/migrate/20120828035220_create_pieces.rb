class CreatePieces < ActiveRecord::Migration
  def change
    create_table :pieces do |t|
      t.string :name, :null => false, :limit => 50
      t.boolean :active, :null => false, :default => true

      t.timestamps
    end
  end
end
