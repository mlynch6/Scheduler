module AuthMacros
  def log_in(attributes = {})
    @_current_user = FactoryGirl.create(:user, attributes)
    visit login_path
    fill_in "Username", with: @_current_user.username
    fill_in "Password", with: @_current_user.password
    click_button "Sign In"
    page.should have_content "Logged in"
  end

  def current_user
    @_current_user
  end
end