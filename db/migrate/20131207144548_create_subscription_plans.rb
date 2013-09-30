class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.string :name, :null => false, :limit => 50
      t.decimal :amount, :null => false, :precision => 7, :scale => 2

      t.timestamps
    end
  end
end
