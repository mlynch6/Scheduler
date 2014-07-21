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
		sequence(:name)	{ |n| "Character #{n}" }
		
		after_build do |char|
			# association :account
			char.account = FactoryGirl.create(:account) unless char.account
			
			# association :piece
			char.piece = FactoryGirl.create(:piece, account: char.account) unless char.piece
		end
		
	 	trait :male do
			gender 					'Male'
		end
		
	 	trait :female do
			gender 					'Female'
		end
		
	 	trait :animal do
			animal 					true
		end
		
	 	trait :child do
			is_child 				true
		end
		
	 	trait :speaking do
			speaking 				true
		end
		
	 	trait :deleted do
			deleted 				true
		end
	end
end
