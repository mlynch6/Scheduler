require 'spec_helper'

RSpec::Matchers.define :allow do |*args|
	match do |permission|
		permission.allow?(*args).should be_true
	end
end

describe Permission do
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
		it { should_not allow(:accounts, :edit) }
		it { should_not allow(:accounts, :update) }
		it { should_not allow(:accounts, :show) }
		
		it { should_not allow(:agma_profiles, :edit) }
		it { should_not allow(:agma_profiles, :update) }

		it { should_not allow(:locations, :index) }
		it { should_not allow(:locations, :new) }
		it { should_not allow(:locations, :create) }
		it { should_not allow(:locations, :edit) }
		it { should_not allow(:locations, :update) }
		it { should_not allow(:locations, :destroy) }
		it { should_not allow(:locations, :inactive) }
		it { should_not allow(:locations, :activate) }
		it { should_not allow(:locations, :inactivate) }
		
		it { should_not allow(:pieces, :index) }
		it { should_not allow(:pieces, :new) }
		it { should_not allow(:pieces, :create) }
		it { should_not allow(:pieces, :edit) }
		it { should_not allow(:pieces, :update) }
		it { should_not allow(:pieces, :destroy) }
		it { should_not allow(:pieces, :inactive) }
		it { should_not allow(:pieces, :activate) }
		it { should_not allow(:pieces, :inactivate) }
		
		it { should_not allow(:employees, :index) }
		it { should_not allow(:employees, :new) }
		it { should_not allow(:employees, :create) }
		it { should_not allow(:employees, :edit) }
		it { should_not allow(:employees, :update) }
		it { should_not allow(:employees, :destroy) }
		it { should_not allow(:employees, :inactive) }
		it { should_not allow(:employees, :activate) }
		it { should_not allow(:employees, :inactivate) }
		
		it { should_not allow(:events, :index) }
		
		it { should_not allow(:rehearsals, :show) }
		it { should_not allow(:rehearsals, :new) }
		it { should_not allow(:rehearsals, :create) }
		
		it { should_not allow(:company_classes, :show) }
		it { should_not allow(:company_classes, :new) }
		it { should_not allow(:company_classes, :create) }
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
		it { should_not allow(:accounts, :edit) }
		it { should_not allow(:accounts, :update) }
		it { should_not allow(:accounts, :show) }
		
		it { should_not allow(:agma_profiles, :edit) }
		it { should_not allow(:agma_profiles, :update) }
		
		it { should allow(:locations, :index) }
		it { should_not allow(:locations, :new) }
		it { should_not allow(:locations, :create) }
		it { should_not allow(:locations, :edit) }
		it { should_not allow(:locations, :update) }
		it { should_not allow(:locations, :destroy) }
		it { should_not allow(:locations, :inactive) }
		it { should_not allow(:locations, :activate) }
		it { should_not allow(:locations, :inactivate) }
		
		it { should allow(:pieces, :index) }
		it { should_not allow(:pieces, :new) }
		it { should_not allow(:pieces, :create) }
		it { should_not allow(:pieces, :edit) }
		it { should_not allow(:pieces, :update) }
		it { should_not allow(:pieces, :destroy) }
		it { should_not allow(:pieces, :inactive) }
		it { should_not allow(:pieces, :activate) }
		it { should_not allow(:pieces, :inactivate) }
		
		it { should allow(:employees, :index) }
		it { should_not allow(:employees, :new) }
		it { should_not allow(:employees, :create) }
		it { should_not allow(:employees, :edit) }
		it { should_not allow(:employees, :update) }
		it { should_not allow(:employees, :destroy) }
		it { should_not allow(:employees, :inactive) }
		it { should_not allow(:employees, :activate) }
		it { should_not allow(:employees, :inactivate) }
		
		it { should allow(:events, :index) }
		
		it { should allow(:rehearsals, :show) }
		it { should_not allow(:rehearsals, :new) }
		it { should_not allow(:rehearsals, :create) }
		
		it { should allow(:company_classes, :show) }
		it { should_not allow(:company_classes, :new) }
		it { should_not allow(:company_classes, :create) }
	end
	
	context "as Administrator" do
		let(:user) { FactoryGirl.create(:admin) }
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
		it { should allow(:accounts, :edit) }
		it { should allow(:accounts, :update) }
		it { should allow(:accounts, :show) }
		
		it { should allow(:agma_profiles, :edit) }
		it { should allow(:agma_profiles, :update) }
		
		it { should allow(:locations, :index) }
		it { should allow(:locations, :new) }
		it { should allow(:locations, :create) }
		it { should allow(:locations, :edit) }
		it { should allow(:locations, :update) }
		it { should_not allow(:locations, :destroy) }
		it { should allow(:locations, :inactive) }
		it { should allow(:locations, :activate) }
		it { should allow(:locations, :inactivate) }
		
		it { should allow(:pieces, :index) }
		it { should allow(:pieces, :new) }
		it { should allow(:pieces, :create) }
		it { should allow(:pieces, :edit) }
		it { should allow(:pieces, :update) }
		it { should_not allow(:pieces, :destroy) }
		it { should allow(:pieces, :inactive) }
		it { should allow(:pieces, :activate) }
		it { should allow(:pieces, :inactivate) }
		
		it { should allow(:employees, :index) }
		it { should allow(:employees, :new) }
		it { should allow(:employees, :create) }
		it { should allow(:employees, :edit) }
		it { should allow(:employees, :update) }
		it { should_not allow(:employees, :destroy) }
		it { should allow(:employees, :inactive) }
		it { should allow(:employees, :activate) }
		it { should allow(:employees, :inactivate) }
		
		it { should allow(:events, :index) }
		
		it { should allow(:rehearsals, :show) }
		it { should allow(:rehearsals, :new) }
		it { should allow(:rehearsals, :create) }
		
		it { should allow(:company_classes, :show) }
		it { should allow(:company_classes, :new) }
		it { should allow(:company_classes, :create) }
	end
	
	context "as Super Administrator" do
		let(:user) { FactoryGirl.create(:superadmin) }
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
		it { should allow(:accounts, :edit) }
		it { should allow(:accounts, :update) }
		it { should allow(:accounts, :show) }
		
		it { should allow(:agma_profiles, :edit) }
		it { should allow(:agma_profiles, :update) }
		
		it { should allow(:locations, :index) }
		it { should allow(:locations, :new) }
		it { should allow(:locations, :create) }
		it { should allow(:locations, :edit) }
		it { should allow(:locations, :update) }
		it { should allow(:locations, :destroy) }
		it { should allow(:locations, :inactive) }
		it { should allow(:locations, :activate) }
		it { should allow(:locations, :inactivate) }
		
		it { should allow(:pieces, :index) }
		it { should allow(:pieces, :new) }
		it { should allow(:pieces, :create) }
		it { should allow(:pieces, :edit) }
		it { should allow(:pieces, :update) }
		it { should allow(:pieces, :destroy) }
		it { should allow(:pieces, :inactive) }
		it { should allow(:pieces, :activate) }
		it { should allow(:pieces, :inactivate) }
		
		it { should allow(:employees, :index) }
		it { should allow(:employees, :inactive) }
		it { should allow(:employees, :new) }
		it { should allow(:employees, :create) }
		it { should allow(:employees, :edit) }
		it { should allow(:employees, :update) }
		it { should allow(:employees, :destroy) }
		it { should allow(:employees, :activate) }
		it { should allow(:employees, :inactivate) }
		
		it { should allow(:events, :index) }
		
		it { should allow(:rehearsals, :new) }
		it { should allow(:rehearsals, :create) }
		it { should allow(:rehearsals, :show) }
		
		it { should allow(:company_classes, :show) }
		it { should allow(:company_classes, :new) }
		it { should allow(:company_classes, :create) }
	end
end