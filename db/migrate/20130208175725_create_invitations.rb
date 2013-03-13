class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :event_id, :null => false
      t.integer :employee_id, :null => false

      t.timestamps
    end

    add_index :invitations, :event_id
    add_index :invitations, :employee_id
    add_index :invitations, [:event_id, :employee_id], :unique => true
  end
end
