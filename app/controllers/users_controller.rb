class UsersController < ApplicationController
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
  
  def index
  	@users = User.paginate(page: params[:page], per_page: params[:per_page])
	end

	def edit
		@user = User.find(params[:id])
		form_setup
	end
	
	def update
		@user = User.find(params[:id], :readonly => false)
		if @user.update_attributes(params[:user])
			redirect_to users_path, :notice => "Successfully updated the user."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		User.find(params[:id]).destroy
		redirect_to users_path, :notice => "Successfully deleted the user."
	end

private

	#setup for form - dropdowns, etc
	def form_setup
		@employees = Employee.active.without_user.map { |employee| [employee.full_name, employee.id] }
	end
end
