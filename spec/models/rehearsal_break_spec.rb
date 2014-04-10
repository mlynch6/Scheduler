# == Schema Information
#
# Table name: rehearsal_breaks
#
#  id               :integer          not null, primary key
#  agma_contract_id :integer          not null
#  break_min        :integer          not null
#  duration_min     :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe RehearsalBreak do
	let(:account) { FactoryGirl.create(:account) }
	let(:contract) { account.agma_contract }
	let(:rehearsal_break) { FactoryGirl.create(:rehearsal_break, agma_contract: contract,
				break_min: 5,
				duration_min: 60) }
  
	before do
		Account.current_id = account.id
		@break = FactoryGirl.build(:rehearsal_break, agma_contract: contract)
	end
  
	subject { @break }
  
	context "accessible attributes" do
		it { should respond_to(:agma_contract) }
		it { should respond_to(:break_min) }
		it { should respond_to(:duration_min) }
  
		it "should not allow access to agma_contract_id" do
			expect do
				RehearsalBreak.new(agma_contract_id: contract.id)
			end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
	end
  
	context "(Valid)" do  	
		it "with minimum attributes" do
			should be_valid
		end
	end
  
	context "(Invalid)" do
		context "when break_min" do
			it "is blank" do
				@break.break_min = " "
				should_not be_valid
			end
        
			it "not an integer" do
				vals = ["abc", 8.6]
				vals.each do |invalid_integer|
					@break.break_min = invalid_integer
					should_not be_valid
				end
			end
         
			it "< 0" do
				@break.break_min = -1
				should_not be_valid
			end
         
			it ">= duration_min" do
				@break.break_min = @break.duration_min
				should_not be_valid
			end
		end
      
		context "when duration_min" do
			it "is blank" do
				@break.duration_min = " "
				should_not be_valid
			end
        
			it "not an integer" do
				vals = ["abc", 8.6]
				vals.each do |invalid_integer|
					@break.duration_min = invalid_integer
					should_not be_valid
				end
			end
         
			it "< 0" do
				@break.duration_min = -1
				should_not be_valid
			end
        
			it "= 0" do
				@break.duration_min = 0
				should_not be_valid
			end
         
			it ">= Max rehearsal time per day (in min)" do
				@break.break_min = contract.rehearsal_max_hrs_per_day * 60
				should_not be_valid
			end
		end
	end
  
	context "(Associations)" do
		it "has one agma_contract" do
			rehearsal_break.reload.agma_contract.should == contract
		end
	end
  
	context "correct value is returned for" do
		it "break_min" do
			rehearsal_break.reload.break_min.should == 5
		end
      
		it "duration_min" do
			rehearsal_break.reload.break_min.should == 5
		end
	end
  
	context "(Uniqueness)" do
		it "by Contract/Duration" do
			@break.agma_contract = rehearsal_break.agma_contract
			@break.duration_min = rehearsal_break.duration_min
			should_not be_valid
		end
	end
  
	describe "(Scopes)" do
		before do
			contract.rehearsal_breaks.delete_all
		end
    
		let!(:second_break) { FactoryGirl.create(:rehearsal_break, agma_contract: contract, duration_min: 90) }
		let!(:first_break) { FactoryGirl.create(:rehearsal_break, agma_contract: contract, duration_min: 60) }
  
		describe "default_scope" do
			it "returns the records in duration order - lowest to highest" do
				RehearsalBreak.all.should == [first_break, second_break]
			end
		end
	end
end
