# == Schema Information
#
# Table name: costume_fittings
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  season_id  :integer          not null
#  title      :string(30)       not null
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CostumeFitting < ActiveRecord::Base
  attr_accessible :title, :comment, :season_id
	attr_accessible :location_id, :start_date, :start_time, :duration

	belongs_to :account
	belongs_to :season
	has_one :event, :as => :schedulable, dependent: :destroy
	has_one :location, :through => :event
	
	delegate :start_date, :start_time, :duration, :time_range, to: :event
	
	validates :account_id,	presence: true
	validates :season_id,	presence: true
	validates :title, presence: true, length: { maximum: 30 }
	
	default_scope lambda { where(:account_id => Account.current_id) }
	
	def self.search(query)
		#Default show all
		costume_fittings = CostumeFitting.joins(:event)
		
		if query.include?(:title) && query[:title].present?
			costume_fittings = costume_fittings.where('costume_fittings.title LIKE :q', q: "%#{query[:title]}%")
		end
		
		if query.include?(:season) && query[:season].present?
			costume_fittings = costume_fittings.where(season_id: query[:season])
		end

		if query.include?(:loc) && query[:loc].present?
			costume_fittings = costume_fittings.where(events: { location_id: query[:loc] })
		end
		
		costume_fittings
	end
end
