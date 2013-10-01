class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name, :null => false, :limit => 100
      t.string :time_zone, :null => false, :limit => 100
      t.string :status, :null => false, :limit => 20
      t.timestamp :cancelled_at
      t.string :stripe_customer_token, :limit => 100
      t.integer :current_subscription_plan_id, :null => false

      t.timestamps
    end
  end
end
