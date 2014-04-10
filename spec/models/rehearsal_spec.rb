# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  title           :string(30)       not null
#  type            :string(20)       default("Event"), not null
#  location_id     :integer          not null
#  start_at        :datetime         not null
#  end_at          :datetime         not null
#  piece_id        :integer
#  event_series_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'
require 'application_helper'

describe Rehearsal do
	let(:account) { FactoryGirl.create(:account) }
	let(:contract) { account.agma_contract }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:piece) { FactoryGirl.create(:piece, account: account) }
	let(:rehearsal) { FactoryGirl.create(:rehearsal,
											account: account,
											location: location,
											title: 'Test Rehearsal',
											start_date: Date.new(2012,1,1),
											start_time: "9AM",
											duration: 60,
											piece: piece) }
	before do
		Account.current_id = account.id
		@rehearsal = FactoryGirl.build(:rehearsal)
	end
	
	subject { @rehearsal }

	context "accessible attributes" do
		it { should respond_to(:piece) }
		it { should respond_to(:break_time) }
		it { should respond_to(:break_duration) }
  	
    it "should allow access to piece_id" do
			expect do
				Rehearsal.new(piece_id: piece.id)
			end.not_to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
	end
	
	context "(Valid)" do
		it "with minimum attributes" do
			should be_valid
			rehearsal.warnings.count.should == 0
		end
	  	
		it "when start_time is the same as rehearsal_start" do
			@rehearsal.start_time = contract.rehearsal_start_time
			@rehearsal.duration = 60
			should be_valid
		end
	  	
		it "when end_time is the same as rehearsal_end" do
			@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_end_min - 60)
			@rehearsal.duration = 60
			should be_valid
		end
	  	
		it "when duration is a multiple of rehearsal_increment_min" do
			@rehearsal.start_time = contract.rehearsal_start_time
			@rehearsal.duration = contract.rehearsal_increment_min
			should be_valid
		end
	  	
		it "when start_time is at the end of the Company Class break" do
			FactoryGirl.create(:company_class,
						account: account,
						start_date: Time.zone.today,
						start_time: contract.rehearsal_start_time,
						duration: 60)
						
			@rehearsal.start_date = Time.zone.today
			@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_start_min + 60 + contract.class_break_min)
			@rehearsal.duration = contract.rehearsal_increment_min
			should be_valid
		end
	end
  
  context "(Invalid)" do
		it "when piece is blank" do
			@rehearsal.piece_id = " "
			should_not be_valid
		end
	  	
		it "when duration is NOT multiple of rehearsal_increment_min" do
			@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_start_min)
			@rehearsal.duration = contract.rehearsal_increment_min - 5
			should_not be_valid
		end
	  	
		it "when start_time is before rehearsal_start" do
			@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_start_min - 15)
			@rehearsal.duration = contract.rehearsal_increment_min
			should_not be_valid
		end
	  	
		it "when end_time is after AgmaContract rehearsal_end" do
			@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_end_min - 5)
			@rehearsal.duration = contract.rehearsal_increment_min
			should_not be_valid
		end
  	
		describe "when start_time" do
			let!(:company_class) { FactoryGirl.create(:company_class,
						account: account,
						start_date: Time.zone.today,
						start_time: min_to_formatted_time(contract.rehearsal_start_min),
						duration: contract.rehearsal_increment_min
						) }
				
			it "is at the beginning of the Company Class break" do
				@rehearsal.start_date = Time.zone.today
				@rehearsal.start_time = company_class.end_time
				should_not be_valid
			end
	  		
			it "is during the Company Class break" do
				@rehearsal.start_date = Time.zone.today
				@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_start_min + contract.rehearsal_increment_min + 5)
				should_not be_valid
			end
		end
  end
	
  context "(Associations)" do
		it "has one piece" do
			rehearsal.reload.piece.should == piece
		end
  end
  
  context "correct value is returned for" do  
	  it "type" do
			rehearsal.reload.type.should == 'Rehearsal'
	  end
	  
	  it "break?" do
			rehearsal.break?.should be_true
	  end
	end
	
	context "(Methods)" do
		describe "relating to breaks:" do
			describe "when no agma_contract record exists" do
				before do
					contract.destroy
				end
				
				it "has break_duration = 0" do
					rehearsal.break_duration.should == 0
				end
				
				it "has break_time of nil" do
					rehearsal.break_time.should be_nil
				end
			end
			
			describe "when no break records exist" do
				before do
					contract.rehearsal_breaks.destroy_all
				end
				
				it "has break_duration = 0" do
					rehearsal.break_duration.should == 0
				end
				
				it "has break_time of nil" do
					rehearsal.break_time.should be_nil
				end
			end
			
			describe "with break records" do
				let!(:break60) { FactoryGirl.create(:rehearsal_break, agma_contract: contract, 
						break_min: 5,
						duration_min: 60 )}
				let!(:break90) { FactoryGirl.create(:rehearsal_break, agma_contract: contract, 
						break_min: 10,
						duration_min: 90 )}
				
				it "break_duration returns correct break_min" do
					rehearsal.break_duration.should == 5
				end
				
				it "break_time returns correct text" do
					rehearsal.break_time.should == "9:55 AM to 10:00 AM"
				end
			
				it "break_duration for 90 min rehearsal" do
					rehearsal.duration = 90
					rehearsal.save
					
					rehearsal.break_duration.should == 10
				end
			end
		end
	end
	
	context "(Warnings)" do
		let(:location2) { FactoryGirl.create(:location, account: account) }
		let(:e1) { FactoryGirl.create(:dancer, account: account) }
		let(:e2) { FactoryGirl.create(:dancer, account: account) }
		let(:e3) { FactoryGirl.create(:dancer, account: account) }
		
		context "when employee is double booked" do
			let!(:rehearsal1) { FactoryGirl.create(:rehearsal, account: account, 
													location: location2,
													start_date: Time.zone.today,
													start_time: "9AM",
													duration: 30,
													employee_ids: [e1.id, e2.id, e3.id]) }
			
			let!(:rehearsal2) { FactoryGirl.create(:rehearsal, account: account, 
													location: location2,
													start_date: Time.zone.today,
													start_time: "10AM",
													duration: 30,
													employee_ids: [e1.id]) }
			
			it "gives warning message" do
				rehearsal.start_date = Time.zone.today
				rehearsal.start_time = "9AM"
				rehearsal.duration = 90
				rehearsal.employee_ids = [e1.id]
				rehearsal.save
				
				rehearsal.warnings.count.should == 1
				rehearsal.warnings[:emp_double_booked].should == "The following people are double booked during this time: #{e1.full_name}"
			end
		end
		
		context "when employee has reached maximum rehearsal hours in day" do
			let!(:r_6hr) { FactoryGirl.create(:rehearsal, account: account, 
													location: location,
													start_date: Time.zone.today,
													start_time: "10AM",
													duration: 360,
													employee_ids: [e1.id, e2.id, e3.id]) }
													
			it "gives warning message" do
				contract.rehearsal_max_hrs_per_day = 6
				contract.save
				
				rehearsal.start_date = Time.zone.today
				rehearsal.start_time = "4PM"
				rehearsal.duration = 30
				rehearsal.employee_ids = [e1.id]
				rehearsal.save
				
				rehearsal.warnings.count.should == 1
				rehearsal.warnings[:emp_max_hr_per_day].should == "The following people are over their rehearsal limit of #{contract.rehearsal_max_hrs_per_day} hrs/day: #{e1.full_name}"
			end
		end
		
		context "when employee has reached maximum rehearsal hours in a week" do
			let!(:mon_6hr) { FactoryGirl.create(:rehearsal, account: account, 
													location: location,
													start_date: Date.new(2014,1,6),
													start_time: "10AM",
													duration: 360,
													employee_ids: [e1.id, e2.id, e3.id]) }
			let!(:tues_6hr) { FactoryGirl.create(:rehearsal, account: account, 
													location: location,
													start_date: Date.new(2014,1,7),
													start_time: "10AM",
													duration: 360,
													employee_ids: [e1.id, e2.id, e3.id]) }
			let!(:wed_6hr) { FactoryGirl.create(:rehearsal, account: account, 
													location: location,
													start_date: Date.new(2014,1,8),
													start_time: "10AM",
													duration: 360,
													employee_ids: [e1.id, e2.id, e3.id]) }
			let!(:thurs_6hr) { FactoryGirl.create(:rehearsal, account: account, 
													location: location,
													start_date: Date.new(2014,1,9),
													start_time: "10AM",
													duration: 360,
													employee_ids: [e1.id, e2.id, e3.id]) }
			let!(:fri_6hr) { FactoryGirl.create(:rehearsal, account: account, 
													location: location,
													start_date: Date.new(2014,1,10),
													start_time: "10AM",
													duration: 360,
													employee_ids: [e1.id, e3.id]) }
			
			it "gives warning message" do
				contract.rehearsal_max_hrs_per_day = 6
				contract.rehearsal_max_hrs_per_week = 30
				contract.save
				
				rehearsal.start_date = Date.new(2014,1,11)
				rehearsal.start_time = "10AM"
				rehearsal.duration = 30
				rehearsal.employee_ids = [e1.id, e2.id]
				rehearsal.save
				
				rehearsal.warnings.count.should == 1
				rehearsal.warnings[:emp_max_hr_per_week].should == "The following people are over their rehearsal limit of #{contract.rehearsal_max_hrs_per_week} hrs/week: #{e1.full_name}"
			end
		end
	end
end
