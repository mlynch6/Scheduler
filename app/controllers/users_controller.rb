class UsersController < ApplicationController
	before_filter :load_and_authorize_person, only: [:new, :create]
	before_filter :build_new_user, only: [:new, :create]
	load_and_authorize_resource :user

  def index
  	@users = @users.includes(:person).paginate(page: params[:page], per_page: params[:per_page])
	end
	
  def new
  end
  
  def create
  	if @user.save
  		redirect_to @person.profile, notice: "Successfully created the user."
  	else
  		render "new"
  	end
  end
	
	def edit
		form_setup
	end
	
	def update
		if @user.update_attributes(params[:user])
			redirect_to employee_path(@user.person.profile), :notice => "Successfully updated the permissions."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@user.destroy
		redirect_to users_path, :notice => "Successfully deleted the user."
	end

private
	def load_and_authorize_person
		@person = Person.find(params[:person_id])
		authorize! :read, @person
	end
	
	def build_new_user
		@user = @person.build_user(params[:user])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
		@roles = Dropdown.of_type('UserRole').active
	end
end
