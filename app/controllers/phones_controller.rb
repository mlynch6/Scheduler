class PhonesController < ApplicationController
	before_filter :load_and_authorize_parent
	load_and_authorize_resource :phone, :through => :phoneable

  def new
  	form_setup
  end
  
  def create
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
	#setup for form - dropdowns, etc
	def form_setup
	end
	
	def load_and_authorize_parent
		resource, id = request.path.split('/')[1, 2]
		@phoneable = resource.singularize.classify.constantize.find(id)
		authorize! :read, @phoneable
	end
end
