require 'spec_helper'

describe Lovs do
	it "ACTIVE contains correct values" do
		Lovs::ACTIVE['Active'].should == 1
		Lovs::ACTIVE['Inactive'].should == 0
	end
end