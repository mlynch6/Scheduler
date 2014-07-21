class ChangeEmployeeIdOnUsers < ActiveRecord::Migration
  def change
		rename_column :users, :employee_id, :person_id
  end
end
