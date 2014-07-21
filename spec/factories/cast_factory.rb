# == Schema Information
#
# Table name: casts
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  season_piece_id :integer          not null
#  name            :string(20)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
	factory :cast do
		#sequence(:name)	{ |n| "Cast #{n}" } #Name defaulted in
		
		after_build do |cast|
			# association :account
			cast.account = FactoryGirl.create(:account) unless cast.account
			
			# association :season_piece
			cast.season_piece = FactoryGirl.create(:season_piece, account: cast.account) unless cast.season_piece
		end
	end
end
