class RemoveRoleFromEmployees < ActiveRecord::Migration
  def up
    remove_column :employees, :role
		
		add_column :employees, :job_title, :string, :limit => 50
		add_column :employees, :agma_artist, :boolean, :null => false, :default => false
  end

  def down
    add_column :employees, :role, :string, :limit => 50
		
		remove_column :employees, :job_title
		remove_column :employees, :agma_artist
  end
end
