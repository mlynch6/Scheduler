class UserMailer < ActionMailer::Base
  default from: "support@stephen-hassard.com"

  def password_reset(user)
		@user = user
		@person = Person.unscoped.find_by_id(user.person_id)
    mail :to => @person.email, :subject => 'Password Reset'
  end
end
