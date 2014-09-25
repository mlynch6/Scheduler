module AuthMacros
  def log_in(attributes = {})
    create_user(:superadmin)
    do_user_login
  end
  
  def log_in_employee(attributes = {})
    create_user(attributes)
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
		account.current_subscription_plan_id = 1	#valid Stripe subscription
		account.save_with_payment
	end
	
	def destroy_stripe_account(account)
  	customer = Stripe::Customer.retrieve(account.stripe_customer_token)
    customer.delete
	end
  
protected
	def create_user(user_role = nil)
		if user_role == :superadmin
			@_current_user = FactoryGirl.build(:user, :superadmin)
		elsif user_role.present?
			@_current_user = FactoryGirl.build(:user, :with_role, role_name: user_role)
		else
			@_current_user = FactoryGirl.build(:user)
		end
		
		unless @_current_user.valid?
			#Make unique username if duplicated
			@_current_user.username = "#{@_current_user.username}_unq" if u.errors.has_key?(:username)
		end
		@_current_user.save
	end
	
	def do_user_login
    visit login_path
    fill_in "username", with: @_current_user.username
    fill_in "password", with: @_current_user.password
    click_button "Sign In"
    page.should have_content "Sign Out"
	end
end