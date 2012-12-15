require 'spec_helper'

RSpec::Matchers.define :allow do |*args|
	match do |permission|
		permission.allow?(*args).should be_true
	end
end

describe Permission, focus: true do
	context "as guest" do
		subject { Permission.new(nil) }
		
		it { should allow(:static_pages, :home) }
		it { should allow(:static_pages, :features) }
		it { should allow(:static_pages, :pricing) }
		it { should allow(:static_pages, :contact) }
		it { should_not allow(:static_pages, :dashboard) }
		
		it { should allow(:sessions, :new) }
		it { should allow(:sessions, :create) }
		it { should allow(:sessions, :destroy) }
		
		it { should allow(:accounts, :new) }
		it { should allow(:accounts, :create) }

#		it { should_not allow(:locations, :index) }
#		it { should_not allow(:locations, :new) }
#		it { should_not allow(:locations, :create) }
#		it { should_not allow(:locations, :edit) }
#		it { should_not allow(:locations, :update) }
#		it { should_not allow(:locations, :destroy) }
#		
#		it { should_not allow(:pieces, :index) }
#		it { should_not allow(:pieces, :new) }
#		it { should_not allow(:pieces, :create) }
#		it { should_not allow(:pieces, :edit) }
#		it { should_not allow(:pieces, :update) }
#		it { should_not allow(:pieces, :destroy) }
#		it { should_not allow(:pieces, :show) }
#
#		it { should_not allow(:users, :new) }
#		it { should_not allow(:users, :create) }
#
#		it { should_not allow(:scenes, :index) }
#		it { should_not allow(:scenes, :new) }
#		it { should_not allow(:scenes, :create) }
#		it { should_not allow(:scenes, :edit) }
#		it { should_not allow(:scenes, :update) }
#		it { should_not allow(:scenes, :destroy) }
#		it { should_not allow(:scenes, :show) }
#
#		it { should_not allow(:roles, :index) }
#		it { should_not allow(:roles, :new) }
#		it { should_not allow(:roles, :create) }
#		it { should_not allow(:roles, :edit) }
#		it { should_not allow(:roles, :update) }
#		it { should_not allow(:roles, :destroy) }
	end
	
	context "as Employee" do
		let(:user) { FactoryGirl.create(:user) }
		subject { Permission.new(user) }
		
		it { should allow(:static_pages, :home) }
		it { should allow(:static_pages, :features) }
		it { should allow(:static_pages, :pricing) }
		it { should allow(:static_pages, :contact) }
		it { should allow(:static_pages, :dashboard) }
		
		it { should allow(:sessions, :new) }
		it { should allow(:sessions, :create) }
		it { should allow(:sessions, :destroy) }
		
		it { should allow(:accounts, :new) }
		it { should allow(:accounts, :create) }
	end
	
	context "as Administrator" do
		let(:admin) { FactoryGirl.create(:admin) }
		subject { Permission.new(admin) }
		
		it { should allow(:static_pages, :home) }
		it { should allow(:static_pages, :features) }
		it { should allow(:static_pages, :pricing) }
		it { should allow(:static_pages, :contact) }
		it { should allow(:static_pages, :dashboard) }
		
		it { should allow(:sessions, :new) }
		it { should allow(:sessions, :create) }
		it { should allow(:sessions, :destroy) }
		
		it { should allow(:accounts, :new) }
		it { should allow(:accounts, :create) }
	end
	
	context "as Super Administrator" do
		let(:superadmin) { FactoryGirl.create(:superadmin) }
		subject { Permission.new(superadmin) }
		
		it { should allow(:static_pages, :home) }
		it { should allow(:static_pages, :features) }
		it { should allow(:static_pages, :pricing) }
		it { should allow(:static_pages, :contact) }
		it { should allow(:static_pages, :dashboard) }
		
		it { should allow(:sessions, :new) }
		it { should allow(:sessions, :create) }
		it { should allow(:sessions, :destroy) }
		
		it { should allow(:accounts, :new) }
		it { should allow(:accounts, :create) }
	end
end