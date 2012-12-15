class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.integer :account_id, :null => false
      t.string :first_name, :null => false, :limit => 30
      t.string :last_name, :null => false, :limit => 30
      t.boolean :active, :null => false, :default => true
      t.string :job_title, :limit => 50
      t.string :email, :limit => 50
      t.string :phone, :limit => 13

      t.timestamps
    end
    add_index :employees, :account_id
  end
end