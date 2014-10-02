class CreateCompanyClass < ActiveRecord::Migration
  def change
    create_table :company_classes do |t|
      t.integer :account_id, 	:null => false
      t.integer :season_id
      t.string :title, 				:null => false, :limit => 30
      t.text :comment
      t.datetime :start_at, 	:null => false
			t.integer :duration, 		:null => false
      t.date :end_date, 			:null => false
			t.integer :location_id, :null => false
			t.boolean :monday, 			:null => false, :default => false
			t.boolean :tuesday, 		:null => false, :default => false
			t.boolean :wednesday, 	:null => false, :default => false
			t.boolean :thursday, 		:null => false, :default => false
			t.boolean :friday, 			:null => false, :default => false
			t.boolean :saturday, 		:null => false, :default => false
			t.boolean :sunday, 			:null => false, :default => false

      t.timestamps
    end
    add_index :company_classes, :account_id
    add_index :company_classes, :season_id
		add_index :company_classes, :location_id
  end
end
