# == Schema Information
#
# Table name: subscription_plans
#
#  id         :integer          not null, primary key
#  name       :string(50)       not null
#  amount     :decimal(7, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
include ActionView::Helpers::NumberHelper

class SubscriptionPlan < ActiveRecord::Base
  attr_accessible :name, :amount
  
  has_many :accounts, foreign_key: "current_subscription_plan_id"
  
  validates :name, presence: true, length: { maximum: 50 }
  validates :amount, presence: true, :numericality => {:greater_than_or_equal_to => 0, :less_than => 1000000 }
  
  def name_and_amount
  	name+" ("+number_to_currency(amount)+")"
	end
end
