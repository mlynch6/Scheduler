class LectureDemoForm
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations
	
	attr_accessor :title, :season_id, :comment
	attr_accessor :start_date, :start_time, :duration, :location_id, :invitee_ids
	
	delegate :title, :season_id, :comment, to: :lecture_demo
	delegate :start_date, :start_time, :duration, :location_id, :invitee_ids, to: :event
	
	validate :validate_lecture_demo
	validate :validate_event
	
	def initialize(form_demo = LectureDemo.new)
		@lecture_demo = form_demo
		@event = @lecture_demo.event
	end
	
	def lecture_demo
		@lecture_demo
	end
	
	def event
		@event ||= lecture_demo.build_event
	end
	
	def submit(params)
		lecture_demo.attributes = params.slice(:title, :season_id, :comment)
		event.attributes = params.slice(:title, :start_date, :start_time, :duration, :location_id, :invitee_ids)
		
		if valid?
			LectureDemo.transaction do
				lecture_demo.save!
				event.save!
			end
			true
		else
			false
		end
	end
	
	def self.model_name
	  ActiveModel::Name.new(self, nil, 'lecture_demo')
	end
	
	def persisted?
		false
	end

private
	def validate_lecture_demo
		lecture_demo.errors.each { |field, msg| errors.add field, msg } unless lecture_demo.valid?
	end
	
	def validate_event
		event.errors.each { |field, msg| errors.add field, msg unless field == :title } unless event.valid?
	end
end