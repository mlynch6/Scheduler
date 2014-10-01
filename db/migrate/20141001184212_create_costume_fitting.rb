class CreateCostumeFitting < ActiveRecord::Migration
  def change
    create_table :costume_fittings do |t|
      t.integer :account_id, :null => false
      t.integer :season_id, :null => false
      t.string :title, :null => false, :limit => 30
      t.text :comment

      t.timestamps
    end
    add_index :costume_fittings, :account_id
    add_index :costume_fittings, :season_id
  end
end
