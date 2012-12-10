class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.integer :account_id, :null => false
    	t.integer :employee_id, :null => false
      t.string :username, :null => false, :limit => 20
      t.string :password_digest, :null => false
      t.string :role, :null => false, :limit => 20

      t.timestamps
    end
    add_index :users, :account_id
    add_index :users, :employee_id
    add_index :users, :username, unique: true
  end
end
