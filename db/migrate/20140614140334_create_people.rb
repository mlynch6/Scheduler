class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer :account_id, :null => false
      t.integer :profile_id, :null => false
      t.string :profile_type, :null => false, :limit => 50
      t.string :first_name, :null => false, :limit => 30
      t.string :middle_name, :limit => 30
      t.string :last_name, :null => false, :limit => 30
      t.string :suffix, :limit => 10
      t.string :gender, :limit => 10
      t.date :birth_date
      t.string :email, :limit => 50
      t.boolean :active, :null => false, :default => true

      t.timestamps
    end
		add_index :people, :account_id
		add_index :people, [:profile_id, :profile_type]
  end
end
