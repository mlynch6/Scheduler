FactoryGirl.define do
	factory :piece do
		sequence(:name)	{ |n| "Piece #{n}" }
  
	  factory :piece_inactive do
			active 	false
		end
	end
end