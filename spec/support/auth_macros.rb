module AuthMacros
  def log_in(attributes = {})
    @_current_user = FactoryGirl.create(:superadmin, attributes)
    do_user_login
  end
  
  def log_in_employee(attributes = {})
    @_current_user = FactoryGirl.create(:user, attributes)
    do_user_login
  end
  
  def log_in_admin(attributes = {})
    @_current_user = FactoryGirl.create(:admin, attributes)
    do_user_login
  end

  def current_user
    @_current_user
  end
  
  def current_account
    @_current_user.employee.account
  end
  
protected
	
	def do_user_login
    visit login_path
    fill_in "Username", with: @_current_user.username
    fill_in "Password", with: @_current_user.password
    click_button "Sign In"
    page.should have_content "Logged in"
	end
end