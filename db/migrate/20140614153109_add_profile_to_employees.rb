class AddProfileToEmployees < ActiveRecord::Migration
  def up
		remove_column :employees, :first_name
		remove_column :employees, :last_name
		remove_column :employees, :email
		remove_column :employees, :active
		add_column :employees, :employee_num, :string, :limit => 20
		add_column :employees, :employment_start_date, :date
		add_column :employees, :employment_end_date, :date
		add_column :employees, :biography, :text
		
		rename_column :invitations, :employee_id, :person_id
  end

  def down
    add_column :employees, :first_name, :string, :null => false, :limit => 30
		add_column :employees, :last_name, :string, :null => false, :limit => 30
		add_column :employees, :email, :string, :limit => 50
		add_column :employees, :active, :boolean, :null => false, :default => true
		remove_column :employees, :employee_num
		remove_column :employees, :employment_start_date
		remove_column :employees, :employment_end_date
		remove_column :employees, :biography
		
		rename_column :invitations, :person_id, :employee_id
  end
end
