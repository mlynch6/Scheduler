require "spec_helper"

describe UserMailer do
  describe "password_reset" do
		let!(:person) { FactoryGirl.create(:person, :complete_record) }
		let!(:user) { FactoryGirl.create(:user,
					account: person.account,
					person: person,
					password_reset_token: "anything") }
		let(:mail) { UserMailer.password_reset(user) }

    it "sends user password reset URL" do
			person.update_attribute(:email, Faker::Internet.email)
			
      mail.subject.should == "Password Reset"
      mail.to.should == [person.email]
      mail.from.should == ["support@stephen-hassard.com"]
			mail.body.encoded.should match(edit_password_reset_url(user.password_reset_token))
    end
	end
end
