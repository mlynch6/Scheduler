class AddProfileToEmployees < ActiveRecord::Migration
  def change
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
end
