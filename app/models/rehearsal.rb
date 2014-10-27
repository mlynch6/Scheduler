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

class Rehearsal < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
	
  attr_accessible :title, :comment, :season_id, :piece_id, :scene_id
	
	belongs_to :account, 	inverse_of: :rehearsals
	belongs_to :season, 	inverse_of: :rehearsals
	belongs_to :piece, 	inverse_of: :rehearsals
	belongs_to :scene, 	inverse_of: :rehearsals
	has_one :event, :as => :schedulable, dependent: :destroy
	has_one :location, :through => :event

	has_many :musician_invitations, :through => :event,
			class_name: 'Invitation', conditions: { role: 'Musician' }
	has_many :musicians, through: :musician_invitations, source: :person
	has_many :artist_invitations, :through => :event,
			class_name: 'Invitation', conditions: { role: 'Artist' }
	has_many :artists, through: :artist_invitations, source: :person
	
	delegate :start_date, :start_time, :duration, :end_time, to: :event
	
	validates :account,	presence: true
	validates :season,	presence: true
	validates :title, presence: true, length: { maximum: 30 }
	validates :piece,	presence: true
	validate :check_contracted_start_time
	validate :check_contracted_end_time
	validate :check_contract_duration
	
	default_scope lambda { where(:account_id => Account.current_id) }
	
	def self.search(query)
		#Default show all
		rehearsals = Rehearsal.joins(:event)
		
		if query.include?(:title) && query[:title].present?
			rehearsals = rehearsals.where('rehearsals.title LIKE :q', q: "%#{query[:title]}%")
		end
		
		if query.include?(:season) && query[:season].present?
			rehearsals = rehearsals.where(season_id: query[:season])
		end

		if query.include?(:loc) && query[:loc].present?
			rehearsals = rehearsals.where(events: { location_id: query[:loc] })
		end
		
		if query.include?(:piece) && query[:piece].present?
			rehearsals = rehearsals.where(piece_id: query[:piece])
		end
		
		rehearsals
	end

	def event
		super || build_event(title: title)
	end

  def time_range
		end_at = event.end_at - break_duration*60
		end_time = end_at.try(:in_time_zone, timezone).try(:to_s, :hr12)
		"#{start_time} to #{end_time}"
	end

	def break_duration
		@break_record ||= get_break_record
		@break_record.present? ? @break_record.break_min : 0
	end

	def break_time_range
		if break_duration == 0
			return nil
		else
			break_start = event.end_at - break_duration*60
			return "#{break_start.in_time_zone(account.time_zone).to_s(:hr12)} to #{event.end_time}"
		end
	end

private
	def check_contracted_start_time
		if start_time.present? && contract && contract.rehearsal_start_min.present? 
			contract_start = Time.parse(contract.rehearsal_start_time)
			rehearsal_start = Time.parse(event.start_time)
			if rehearsal_start < contract_start
				errors.add(:start_time, "can't be before #{contract.rehearsal_start_time}")
			end
		end
	end
	
	def check_contracted_end_time
		if end_time.present? && contract && contract.rehearsal_end_min.present? 
			contract_end = Time.parse(contract.rehearsal_end_time)
			rehearsal_end = Time.parse(event.end_time)
			if rehearsal_end > contract_end
				errors.add(:base, "End Time can't be after #{contract.rehearsal_end_time}")
			end
		end
	end

	def check_contract_duration
		if duration.present? && contract && contract.rehearsal_increment_min.present? 
			increment = contract.rehearsal_increment_min
			if (duration % increment) != 0
				errors.add(:duration, "must be in increments of #{pluralize(increment, 'minute')}")
			end
		end
	end

	def get_break_record
		if contract.present?
			rehearsal_break = contract.rehearsal_breaks.where(duration_min: duration).select('break_min').first
			rehearsal_break if rehearsal_break.present?
		else
			return nil
		end
	end
	
	def timezone
		@timezone ||= Account.find(Account.current_id).time_zone if Account.current_id
		@timezone ||= account.time_zone if account
	end
	
	def contract
		@contract ||= AgmaContract.first
	end
end
