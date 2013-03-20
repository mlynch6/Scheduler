require 'spec_helper'

describe Lovs do
	context "ACTIVE" do
		it "contains correct values" do
			Lovs::ACTIVE['Active'].should == 1
			Lovs::ACTIVE['Inactive'].should == 0
		end
	end	

	context "time_array" do
		it "has from midnight in hour increments" do
			options = Lovs.time_array(60)
			vals = ["12:00 AM", "1:00 AM", "2:00 AM", "3:00 AM", "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"]
			vals.each do |val|
  			options.include?(val).should be_true
  		end
  		options.count.should == 24
		end
		
		it "has from midnight in 15 min increments" do
			options = Lovs.time_array(15)
			vals = ["12:15 AM", "1:30 AM", "2:45 AM", "3:00 AM", "2:30 PM", "3:15 PM", "4:45 PM"]
			vals.each do |val|
  			options.include?(val).should be_true
  		end
  		options.count.should == 24*4
		end
		
		it "should not have extra values" do
			options = Lovs.time_array(60)
			invalid_vals = ["12:30 AM", "1:15 AM", "2:26 AM", "7:10 PM", "8:32 PM", "9:14 PM"]
			invalid_vals.each do |invalid_val|
  			options.include?(invalid_val).should be_false
  		end
		end
	end
end