class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, :null => false, :limit => 30
      t.integer :piece_id, :null => false

      t.timestamps
    end
    add_index :roles, :piece_id
  end
end
