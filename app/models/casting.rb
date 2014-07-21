# == Schema Information
#
# Table name: castings
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  cast_id      :integer          not null
#  character_id :integer          not null
#  person_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Casting < ActiveRecord::Base
	attr_accessible :character_id, :person_id
	
	belongs_to :account, inverse_of: :castings
	belongs_to :cast, inverse_of: :castings
	belongs_to :character, inverse_of: :castings
	belongs_to :person, inverse_of: :castings
	
	validates :account_id, presence: true
	validates :cast_id, presence: true
	validates :character_id, presence: true, :uniqueness => { scope: :cast_id }
	
	default_scope lambda { where(:account_id => Account.current_id) }
end
