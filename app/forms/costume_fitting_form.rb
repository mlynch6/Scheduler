class CostumeFittingForm
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations
	
	attr_accessor :title, :season_id, :comment
	attr_accessor :start_date, :start_time, :duration, :location_id
	
	delegate :title, :season_id, :comment, to: :costume_fitting
	delegate :start_date, :start_time, :duration, :location_id, to: :event
	
	validate :validate_costume_fitting
	validate :validate_event
	
	def initialize(form_fitting = CostumeFitting.new)
		@costume_fitting = form_fitting
		@event = @costume_fitting.event
	end
	
	def costume_fitting
		@costume_fitting
	end
	
	def event
		@event ||= costume_fitting.build_event
	end
	
	def submit(params)
		costume_fitting.attributes = params.slice(:title, :season_id, :comment)
		event.attributes = params.slice(:title, :start_date, :start_time, :duration, :location_id)
		
		if valid?
			CostumeFitting.transaction do
				costume_fitting.save!
				event.save!
			end
			true
		else
			false
		end
	end
	
	def self.model_name
	  ActiveModel::Name.new(self, nil, 'costume_fitting')
	end
	
	def persisted?
		false
	end

private
	def validate_costume_fitting
		costume_fitting.errors.each { |field, msg| errors.add field, msg } unless costume_fitting.valid?
	end
	
	def validate_event
		event.errors.each { |field, msg| errors.add field, msg unless field == :title } unless event.valid?
	end
end