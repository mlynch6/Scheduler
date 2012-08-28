FactoryGirl.define do
	factory :piece do
		name		'Peter Pan'
	end
  
  factory :piece_inactive, :class => Piece do
		name 		'Dracula'
		active 	false
	end
end