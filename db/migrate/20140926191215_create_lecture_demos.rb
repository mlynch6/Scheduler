class CreateLectureDemos < ActiveRecord::Migration
  def change
    create_table :lecture_demos do |t|
      t.integer :account_id, :null => false
      t.integer :season_id, :null => false
      t.string :title, :null => false, :limit => 30
      t.text :comment

      t.timestamps
    end
    add_index :lecture_demos, :account_id
    add_index :lecture_demos, :season_id
  end
end
