class AddressesController < ApplicationController
	before_filter :load_addressable
	
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
		@address = Address.find(params[:id])
		form_setup
	end
	
	def update
		@address = Address.find(params[:id])
		if @address.update_attributes(params[:address])
			redirect_to [@addressable], :notice => "Successfully updated the address."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		Address.find(params[:id]).destroy
		redirect_to [@addressable], :notice => "Successfully deleted the address."
	end

private
	#setup for form - dropdowns, etc
	def form_setup
	end

	def load_addressable
		resource, id = request.path.split('/')[1, 2]
		@addressable = resource.singularize.classify.constantize.find(id)
	end
end
