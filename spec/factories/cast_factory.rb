# == Schema Information
#
# Table name: casts
#
#  id              :integer          not null, primary key
#  season_piece_id :integer          not null
#  name            :string(20)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
	factory :cast do
		season_piece
		#sequence(:name)	{ |n| "Cast #{n}" } #Name defaulted in
	end
end
