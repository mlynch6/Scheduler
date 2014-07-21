# == Schema Information
#
# Table name: scenes
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  piece_id   :integer          not null
#  name       :string(100)      not null
#  position   :integer          not null
#  track      :string(20)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :scene do
		sequence(:name)	{ |n| "Scene #{n}" }
		
		after_build do |scene|
			# association :account
			scene.account = FactoryGirl.create(:account) unless scene.account
			
			# association :piece
			scene.piece = FactoryGirl.create(:piece, account: scene.account) unless scene.piece
		end
	end
end
