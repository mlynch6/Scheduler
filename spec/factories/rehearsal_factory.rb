# == Schema Information
#
# Table name: rehearsals
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  season_id  :integer          not null
#  title      :string(30)       not null
#  piece_id   :integer          not null
#  scene_id   :integer
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :rehearsal do
		sequence(:title)	{ |n| "Rehearsal #{n}" }
		
		after_build do |rehearsal|
			# association :account
			rehearsal.account = FactoryGirl.create(:account) unless rehearsal.account
			# association :season
			rehearsal.season = FactoryGirl.create(:season, account: rehearsal.account) unless rehearsal.season
			# association :piece
			rehearsal.piece = FactoryGirl.create(:piece, account: rehearsal.account) unless rehearsal.piece
		end
		
	  trait :with_scene do
			after_build do |rehearsal|
				# association :scene
				rehearsal.scene = FactoryGirl.create(:scene, account: rehearsal.account, piece: rehearsal.piece) unless rehearsal.scene
			end
		end
	end
end
