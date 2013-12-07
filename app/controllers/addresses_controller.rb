class AddressesController < ApplicationController
	before_filter :load_addressable
	before_filter :get_resource, :only => [:edit, :update, :destroy]
	
  def new
  	form_setup
  	@address = @addressable.addresses.new
  end
  
  def create
  	@address = @addressable.addresses.new(params[:address])
  	if @address.save
			redirect_to [@addressable], :notice => "Successfully created the address."
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
			redirect_to [@addressable], :notice => "Successfully updated the address."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@address.destroy
		redirect_to [@addressable], :notice => "Successfully deleted the address."
	end

private
	def get_resource
		@address = Address.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
	end

	def load_addressable
		resource, id = request.path.split('/')[1, 2]
		@addressable = resource.singularize.classify.constantize.find(id)
	end
end
