class RehearsalForm
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations
	
	attr_accessor :title, :piece_id, :scene_id, :season_id, :comment
	attr_accessor :start_date, :start_time, :duration, :location_id
	
	delegate :title, :piece_id, :scene_id, :season_id, :comment, to: :rehearsal
	delegate :start_date, :start_time, :duration, :location_id, to: :event
	
	validate :validate_rehearsal
	validate :validate_event
	
	def initialize(my_rehearsal = Rehearsal.new)
		@rehearsal = my_rehearsal
		@event = @rehearsal.event
	end
	
	def rehearsal
		@rehearsal
	end
	
	def event
		@event ||= rehearsal.build_event
	end
	
	def submit(params)
		rehearsal.attributes = params.slice(:title, :piece_id, :scene_id, :season_id, :comment)
		event.attributes = params.slice(:title, :start_date, :start_time, :duration, :location_id)
		
		if valid?
			Rehearsal.transaction do
				rehearsal.save!
				event.save!
			end
			true
		else
			false
		end
	end
	
	def self.model_name
	  ActiveModel::Name.new(self, nil, 'rehearsal')
	end
	
	def persisted?
		false
	end

private
	def validate_rehearsal
		rehearsal.errors.each { |field, msg| errors.add field, msg } unless rehearsal.valid?
	end
	
	def validate_event
		event.errors.each { |field, msg| errors.add field, msg unless field == :title } unless event.valid?
	end
end