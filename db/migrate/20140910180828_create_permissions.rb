class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
			t.integer :account_id, :null => false
      t.integer :user_id, :null => false
      t.integer :role_id, :null => false

      t.timestamps
    end
		add_index :permissions, :account_id
    add_index :permissions, :user_id
    add_index :permissions, :role_id
    add_index :permissions, [:account_id, :user_id, :role_id], :unique => true
  end
end
