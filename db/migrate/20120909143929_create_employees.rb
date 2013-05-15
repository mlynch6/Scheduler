class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.integer :account_id, :null => false
      t.string :first_name, :null => false, :limit => 30
      t.string :last_name, :null => false, :limit => 30
      t.boolean :active, :null => false, :default => true
      t.string :role, :limit => 50, :null => false
      t.string :email, :limit => 50

      t.timestamps
    end
    add_index :employees, :account_id
  end
end
