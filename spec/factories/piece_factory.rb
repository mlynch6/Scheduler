# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :piece do
		sequence(:name)	{ |n| "Piece #{n}" }
  
	  factory :piece_inactive do
			active 	false
		end
	end
end
