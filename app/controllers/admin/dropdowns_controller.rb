class Admin::DropdownsController < ApplicationController
	before_filter :get_resource, :only => [:edit, :update, :destroy]
	
	def index
		params[:type] ||= Dropdown::TYPES.first
		query = params.slice(:type, :status, :query)
		@dropdowns = Dropdown.search(query)
	end
	
	def new
		@dropdown = Dropdown.of_type(params[:type]).new
	end
	
	def create
		params[:type] ||= params[:dropdown].delete(:dropdown_type)
		@dropdown = Dropdown.of_type(params[:type]).new(params[:dropdown])
		
		if @dropdown.save
			redirect_to admin_dropdowns_path(type: @dropdown.dropdown_type), :notice => "Successfully created the dropdown."
		else
			render 'new'
		end
	end
	
	def edit
	end
	
	def update
		params[:dropdown].delete(:dropdown_type)
		if @dropdown.update_attributes(params[:dropdown])
			redirect_to admin_dropdowns_path(type: @dropdown.dropdown_type), :notice => "Successfully updated the dropdown."
		else
			render 'edit'
		end
	end
	
	def destroy
		@dropdown.destroy
		redirect_to admin_dropdowns_path(type: @dropdown.dropdown_type), :notice => "Successfully deleted the dropdown."
	end

	def sort
		params[:dropdown].each_with_index do |id, index|
			Dropdown.of_type(params[:type]).update_all({ position: index+1 }, { id: id })
		end
		render nothing: true
	end
	
private
	def get_resource
		@dropdown = Dropdown.find(params[:id])
	end
end
