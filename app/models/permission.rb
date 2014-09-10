# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  user_id    :integer          not null
#  role_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Permission < ActiveRecord::Base
  attr_accessible :role_id, :user_id
	
  belongs_to :account
  belongs_to :user
	belongs_to :role, class_name: 'Dropdown'
	
	validates :user_id,	presence: true
	validates :role_id,	presence: true, uniqueness: { scope: [:account_id, :user_id] }
	
	default_scope lambda { where(:account_id => Account.current_id) }
end
