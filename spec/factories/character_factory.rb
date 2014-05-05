# == Schema Information
#
# Table name: characters
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  piece_id   :integer          not null
#  name       :string(30)       not null
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gender     :string(10)
#  animal     :boolean          default(FALSE), not null
#  is_child   :boolean          default(FALSE), not null
#  speaking   :boolean          default(FALSE), not null
#  deleted    :boolean          default(FALSE), not null
#  deleted_at :datetime
#

FactoryGirl.define do
	factory :character do
		account
		piece
		sequence(:name)	{ |n| "Character #{n}" }
		
	 	factory :character_male do
			gender 					'Male'
		end
		
	 	factory :character_female do
			gender 					'Female'
		end
		
	 	factory :character_animal do
			animal 					true
		end
		
	 	factory :character_child do
			is_child 				true
		end
		
	 	factory :character_speaking do
			speaking 				true
		end
		
	 	factory :character_deleted do
			deleted 				true
		end
	end
end
