class AddRoleToInvitations < ActiveRecord::Migration
  def change
		add_column :invitations, :account_id, :integer, :null => false
    add_column :invitations, :role, :string, :limit => 20
		add_index :invitations, :account_id
  end
end
