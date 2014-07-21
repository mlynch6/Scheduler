class PhonesController < ApplicationController
	before_filter :load_phoneable
	before_filter :get_resource, :only => [:edit, :update, :destroy]

  def new
  	form_setup
  	@phone = @phoneable.phones.new
  end
  
  def create
  	@phone = @phoneable.phones.new(params[:phone])
  	if @phone.save
			flash[:notice] = "Successfully created the phone number."
			if @phoneable.class.name == 'Person'
				redirect_to employee_path(@phoneable.profile)
			else
				redirect_to [@phoneable]
			end
		else
			form_setup
			render :new
		end
  end
  
  def edit
		form_setup
	end
	
	def update
		if @phone.update_attributes(params[:phone])
			flash[:notice] = "Successfully updated the phone number."
			if @phoneable.class.name == 'Person'
				redirect_to employee_path(@phoneable.profile)
			else
				redirect_to [@phoneable]
			end
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@phone.destroy
		flash[:notice] = "Successfully deleted the phone number."
		if @phoneable.class.name == 'Person'
			redirect_to employee_path(@phoneable.profile)
		else
			redirect_to [@phoneable]
		end
	end

private
	def get_resource
		@phone = Phone.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
	end

	def load_phoneable
		resource, id = request.path.split('/')[1, 2]
		@phoneable = resource.singularize.classify.constantize.find(id)
	end
end
