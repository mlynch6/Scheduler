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
		sequence(:name)	{ |n| "Piece #{n}" }
		
		after_build do |piece|
			# association :account
			piece.account = FactoryGirl.create(:account) unless piece.account
		end
			
		trait :complete_record do
			choreographer { Faker::Name.name }
			music 				{ Faker::Lorem.word }
			composer 			{ Faker::Name.name }
			avg_length 		{ Faker::Number.number(2) }
		end
	end
end
