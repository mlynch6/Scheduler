require 'spec_helper'

describe ApplicationHelper, 'full_title' do	
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

describe ApplicationHelper, 'icon_with_text' do	
	it "has the HTML for bootstrap icon and text" do
		icon_with_text("Delete", 'trash').should == '<i class="icon-trash"></i> Delete'
	end
end

describe ApplicationHelper, 'status_dropdown_values' do
	it "has 'Active' status" do
		status_dropdown_values['Active'].should == 1
	end
	
	it "has 'Inactive' status" do
		status_dropdown_values['Inactive'].should == 0
	end
end

describe ApplicationHelper, 'active_bool_to_text' do	
	it "returns 'Active' when true" do
		active_bool_to_text(true).should == 'Active'
	end
	
	it "returns 'Inactive' when false" do
		active_bool_to_text(false).should == 'Inactive'
	end
end