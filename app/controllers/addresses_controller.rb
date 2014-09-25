class AddressesController < ApplicationController
	before_filter :load_and_authorize_parent
	load_and_authorize_resource :address, :through => :addressable
	
  def new
  	form_setup
  end
  
  def create
  	if @address.save
			flash[:notice] = "Successfully created the address."
			if @addressable.class.name == 'Person'
				redirect_to employee_path(@addressable.profile)
			else
				redirect_to [@addressable]
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
		if @address.update_attributes(params[:address])
			flash[:notice] = "Successfully updated the address."
			if @addressable.class.name == 'Person'
				redirect_to employee_path(@addressable.profile)
			else
				redirect_to [@addressable]
			end
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@address.destroy
		flash[:notice] = "Successfully deleted the address."
		if @addressable.class.name == 'Person'
			redirect_to employee_path(@addressable.profile)
		else
			redirect_to [@addressable]
		end
	end

private
	#setup for form - dropdowns, etc
	def form_setup
	end

	def load_and_authorize_parent
		resource, id = request.path.split('/')[1, 2]
		@addressable = resource.singularize.classify.constantize.find(id)
		authorize! :read, @addressable
	end
end
