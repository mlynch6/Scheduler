class AddMusicianToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :musician, 	:boolean, :null => false, :default => false
    add_column :employees, :instructor, :boolean, :null => false, :default => false
  end
end
