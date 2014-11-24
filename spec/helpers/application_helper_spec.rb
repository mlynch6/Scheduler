require 'spec_helper'

describe ApplicationHelper do
	context 'full_title' do	
		it "has the base title when NO page title provided" do
			full_title("").should =~ /^Scheduler/
		end
		
		it "has the base title when page title provided" do
			full_title("foo").should =~ /^Scheduler/
		end
		
		it "has the page title" do
			full_title("foo").should =~ /foo/
		end
		
		it "does NOT have a | (bar) when no page title provided" do
			full_title("").should_not =~ /\|/
		end
	end

	context 'formatted_date' do
		it "formats date in default format" do
			formatted_date('2012-10-09').should == '10/09/2012'
		end
		
		it "formats date in specified format" do
			formatted_date('2012-10-09', '%v').should == ' 9-Oct-2012'
		end
	end
	
	context 'min_to_formatted_time' do
		it "formats am time" do
			min_to_formatted_time(60).should == "1:00 AM"
		end
		
		it "formats pm time" do
			min_to_formatted_time(900).should == "3:00 PM"
		end
	end
	
	context 'readable_klass' do
		it "returns a readable value" do
  		values = ['UserRole', 'user_role', 'user role']
  		values.each do |val|
  			readable_klass(val).should == 'User Role'
  		end
		end
		
		it "returns a blank if input is empty" do
			readable_klass('').should == ''
			readable_klass(nil).should == ''
		end
	end
	
	context 'bootstrap_icon' do
		it "returns html for bootstrap glyphicon" do
  		bootstrap_icon('bell').should == '<span class="glyphicon glyphicon-bell"></span>'
		end
	end
end