class RemoveRoleFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :role
  end

  def down
    add_column :users, :role, :string, :null => false, :limit => 20, :default => 'Employee'
  end
end
