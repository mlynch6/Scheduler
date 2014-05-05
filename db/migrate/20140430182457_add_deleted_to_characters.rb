class AddDeletedToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :gender, :string, :limit => 10
		add_column :characters, :animal, :boolean, :null => false, :default => false
		add_column :characters, :is_child, :boolean, :null => false, :default => false
		add_column :characters, :speaking, :boolean, :null => false, :default => false
		add_column :characters, :deleted, :boolean, :null => false, :default => false
    add_column :characters, :deleted_at, :datetime
  end
end
