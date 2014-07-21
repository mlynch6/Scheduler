class PasswordsController < ApplicationController
	before_filter :get_resource, :only => [:new, :create]
		
  def new
  end
	
  def create
		if @password_form.submit(params[:password_form])
			redirect_to current_user.person.profile, notice: "Password has been changed."
		else
			render :new
		end
  end

private
	def get_resource
		@password_form = PasswordForm.new(current_user)
	end
end
