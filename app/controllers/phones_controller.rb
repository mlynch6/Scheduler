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
			redirect_to [@phoneable], :notice => "Successfully created the phone number."
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
			redirect_to [@phoneable], :notice => "Successfully updated the phone number."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@phone.destroy
		redirect_to [@phoneable], :notice => "Successfully deleted the phone number."
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
