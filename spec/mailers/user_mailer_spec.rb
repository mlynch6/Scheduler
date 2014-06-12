require "spec_helper"

describe UserMailer do
  describe "password_reset" do
		let!(:account) { FactoryGirl.create(:account) }
		let!(:employee) { FactoryGirl.create(:employee, 
					account: account, 
					email: Faker::Internet.email) }
		let!(:user) { FactoryGirl.create(:user,
					account: account,
					employee: employee,
					password_reset_token: "anything") }
		let(:mail) { UserMailer.password_reset(user) }

    it "sends user password reset URL" do
      mail.subject.should == "Password Reset"
      mail.to.should == [employee.email]
      mail.from.should == ["support@stephen-hassard.com"]
			mail.body.encoded.should match(edit_password_reset_url(user.password_reset_token))
    end
	end
end
