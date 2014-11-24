require 'spec_helper'

describe ScheduleHelper do
	context 'min_to_words' do
		it "displays correct hours/min" do
			min_to_words(200).should == "3 hours 20 minutes"
		end
		
		it "displays hours as singular" do
			min_to_words(90).should == "1 hour 30 minutes"
		end
		
		it "displays hours as plural" do
			min_to_words(121).should == "2 hours 1 minute"
		end
		
		it "displays minutes as singular" do
			min_to_words(1).should == "1 minute"
		end
		
		it "displays minutes as plural" do
			min_to_words(30).should == "30 minutes"
		end
		
		it "displays hours only when minutes is 0" do
			min_to_words(60).should == "1 hour"
		end
		
		it "displays minutes only when hours is 0" do
			min_to_words(30).should == "30 minutes"
		end
	end
	
	context 'name_or_tbd' do
		it "displays record's name when there is a record" do
			loc = FactoryGirl.create(:location)
			name_or_tbd(loc).should == loc.name
		end
		
		it "displays 'TBD' when there is NO record" do
			loc = nil
			name_or_tbd(loc).should == 'TBD'
		end
	end
end