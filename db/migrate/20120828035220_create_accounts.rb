class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name, :null => false, :limit => 100
      t.string :main_phone, :null => false, :limit => 13
      t.string :time_zone, :null => false, :limit => 100

      t.timestamps
    end
  end
end