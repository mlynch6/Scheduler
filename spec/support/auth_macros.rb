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
  
  def create_stripe_account(account)
  	token = Stripe::Token.create(:card => { :number => "4242424242424242", :exp_month => 7, :exp_year => Date.today.year+1, :cvc => 314 })
		account.stripe_card_token = token.id
		account.current_subscription_plan_id = SubscriptionPlan.first.id
		account.save_with_payment
	end
	
	def destroy_stripe_account(account)
  	customer = Stripe::Customer.retrieve(account.stripe_customer_token)
    customer.delete
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