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
	include ActionView::Helpers::TextHelper
	
  attr_accessible :title, :comment, :season_id

	belongs_to :account, 	inverse_of: :costume_fittings
	belongs_to :season, 	inverse_of: :costume_fittings
	has_one :event, :as => :schedulable, dependent: :destroy
	has_one :location, :through => :event
	
	delegate :start_date, :start_time, :duration, :time_range, to: :event
	
	validates :account,	presence: true
	validates :season,	presence: true
	validates :title, presence: true, length: { maximum: 30 }
	validate :check_contract_duration
	
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
	
	def event
		super || build_event(title: title)
	end

private
	def check_contract_duration
		if duration.present? && contract && contract.costume_increment_min.present? 
			increment = contract.costume_increment_min
			if (duration % increment) != 0
				errors.add(:duration, "must be in increments of #{pluralize(increment, 'minute')}")
			end
		end
	end
	
	def contract
		@contract ||= AgmaContract.first
	end
end
