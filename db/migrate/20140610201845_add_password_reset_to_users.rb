class AddPasswordResetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_token, :string, :limit => 50
    add_column :users, :password_reset_sent_at, :datetime
  end
end
