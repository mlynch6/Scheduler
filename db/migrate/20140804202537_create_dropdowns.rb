class CreateDropdowns < ActiveRecord::Migration
  def change
    create_table :dropdowns do |t|
			t.string 	:dropdown_type, :null => false, :limit => 30
      t.string 	:name, :null => false, :limit => 30
			t.text 	:comment
      t.integer :position, :null => false
      t.boolean :active, :null => false, :default => true

      t.timestamps
    end
    add_index :dropdowns, :dropdown_type
    add_index :dropdowns, [:dropdown_type, :name], :unique => true
  end
end
