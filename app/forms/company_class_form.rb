class CompanyClassForm
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations
	
	####################
	# Using Form Object because start_date & start_time not persisting in form after error
	####################
	
	attr_accessor :title, :season_id, :comment
	attr_accessor :start_date, :start_time, :duration, :end_date, :location_id
	attr_accessor :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
	attr_accessor :instructor_ids, :musician_ids, :artist_ids
	
	delegate :title, :season_id, :comment, to: :company_class
	delegate :start_date, :start_time, :duration, :end_date, :location_id, to: :company_class
	delegate :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, to: :company_class
	
	validate :validate_company_class
	
	def initialize(my_company_class = CompanyClass.new)
		@company_class = my_company_class
	end
	
	def company_class
		@company_class
	end
	
	def submit(params)
		company_class.attributes = params.slice(:title, :season_id, :comment, 
					:start_date, :start_time, :duration, :end_date, :location_id, 
					:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday)
		invitee_attributes = params.slice(:instructor_ids, :musician_ids, :artist_ids)
		
		if valid?
			CompanyClass.transaction do
				company_class.save!
				company_class.events.each do |event|
					event.update_attributes!(invitee_attributes)
				end
			end
			true
		else
			false
		end
	end
	
	def self.model_name
	  ActiveModel::Name.new(self, nil, 'company_class')
	end
	
	def persisted?
		false
	end

private
	def validate_company_class
		company_class.errors.each { |field, msg| errors.add field, msg } unless company_class.valid?
	end
end