# == Schema Information
#
# Table name: pieces
#
#  id            :integer          not null, primary key
#  account_id    :integer          not null
#  name          :string(50)       not null
#  choreographer :string(50)
#  music         :string(50)
#  composer      :string(50)
#  avg_length    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
	factory :piece do
		account
		sequence(:name)	{ |n| "Piece #{n}" }
			
		factory :piece_complete do
			choreographer { Faker::Name.name }
			music 				{ Faker::Lorem.word }
			composer 			{ Faker::Name.name }
			avg_length 		{ Faker::Number.number(2) }
		end
	end
end
