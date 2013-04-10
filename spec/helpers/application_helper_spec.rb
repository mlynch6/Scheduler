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

	context 'link_w_icon' do	
		it "has the HTML for bootstrap icon and text" do
			link_w_icon("Delete", "#", 'trash').should == '<a href="#"><i class="icon-trash"></i>Delete</a>'
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
end