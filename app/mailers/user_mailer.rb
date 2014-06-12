class UserMailer < ActionMailer::Base
  default from: "support@stephen-hassard.com"

  def password_reset(user)
		@user = user
		@employee = Employee.unscoped.find(user.employee_id)
    mail :to => @employee.email, :subject => 'Password Reset'
  end
end
