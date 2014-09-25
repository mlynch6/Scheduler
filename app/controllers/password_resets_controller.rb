class PasswordResetsController < ApplicationController
  authorize_resource :class => false
	
	def new
  end
	
  def create
		person = Person.unscoped.find_by_email(params[:email])
		user = User.unscoped.find_by_person_id(person.id) if person
		user.send_password_reset_email if user
		redirect_to password_resets_path
  end
	
  def index
  end
	
  def edit
		@user = User.unscoped.find_by_password_reset_token!(params[:id])
  end
	
  def update
		@user = User.unscoped.find_by_password_reset_token!(params[:id])
		if @user.password_reset_sent_at < 4.hours.ago
			flash[:error] = "Password reset has expired."
			redirect_to new_password_reset_path
		elsif @user.update_attributes(params[:user])
			redirect_to login_path, notice: "Password has been changed."
		else
			render :edit
		end
  end
end
