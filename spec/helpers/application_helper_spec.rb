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
	
	context 'active_inactive' do
		it "when true displays Active" do
			active_inactive(true).should == 'Active'
		end
		
		it "when false displays Inactive" do
			active_inactive(false).should == 'Inactive'
		end
	end
end