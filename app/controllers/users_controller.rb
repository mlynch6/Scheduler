class UsersController < ApplicationController
	before_filter :get_resource, :only => [:destroy]
	
  def index
  	@users = User.includes(:employee).paginate(page: params[:page], per_page: params[:per_page])
	end
	
  def new
  	form_setup
  	@user = User.new
  end
  
  def create
  	@user = User.new(params[:user])
  	if @user.save
  		redirect_to users_path, notice: "Successfully created the user."
  	else
  		form_setup
  		render "new"
  	end
  end
	
	def destroy
		@user.destroy
		redirect_to users_path, :notice => "Successfully deleted the user."
	end

private
	def get_resource
		@user = User.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
		@employees = Employee.active.without_user.map { |employee| [employee.full_name, employee.id] }
	end
end
