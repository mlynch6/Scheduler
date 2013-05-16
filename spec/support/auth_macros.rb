module AuthMacros
  def log_in(attributes = {})
  	employee = FactoryGirl.create(:employee)
    @_current_user = FactoryGirl.create(:superadmin, employee: employee, account: employee.account)
    do_user_login
  end
  
  def log_in_employee(attributes = {})
  	employee = FactoryGirl.create(:employee)
    @_current_user = FactoryGirl.create(:user, employee: employee, account: employee.account)
    do_user_login
  end
  
  def log_in_admin(attributes = {})
  	employee = FactoryGirl.create(:employee)
    @_current_user = FactoryGirl.create(:admin, employee: employee, account: employee.account)
    do_user_login
  end

  def current_user
    @_current_user
  end
  
  def current_account
    @_current_user.account
  end
  
protected
	
	def do_user_login
    visit login_path
    fill_in "Username", with: @_current_user.username
    fill_in "Password", with: @_current_user.password
    click_button "Sign In"
    page.should have_content "Sign Out"
	end
end