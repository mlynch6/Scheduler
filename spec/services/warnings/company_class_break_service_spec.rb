require 'spec_helper'

describe Warnings do
	context "CompanyClassBreak" do
		before do
			@account = FactoryGirl.create(:account)
			Account.current_id = @account.id
			@contract = @account.agma_contract
			
			@start_date = Date.new(2014,1,1)
			@company_class = FactoryGirl.create(:company_class, :daily,
						account: @account,
						start_date: @start_date.to_s,
						end_date: @start_date.to_s,
						start_time: '10:00 AM',
						duration: 60)
		end
		
		it "#start_date should return the warning's date" do
			@warning = Warnings::CompanyClassBreak.new(@start_date)
			@warning.start_date.should == @start_date
		end
		
		context "without a contract" do
			before do
				@contract.destroy
				@warning = Warnings::CompanyClassBreak.new(@start_date)
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		context "with a contract and class_break_min is blank" do
			before do
				@contract.class_break_min = ""
				@contract.save
				@warning = Warnings::CompanyClassBreak.new(@start_date)
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		context "with a contract break" do
			before do
				@contract.class_break_min = 15
				@contract.save
			end
			
			describe "and rehearsal not within break period" do
				before do
					@rehearsal = FactoryGirl.create(:rehearsal, account: @account)
					@non_overlapping = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal,
								start_date: @start_date,
								start_time: '11:15 AM',
								duration: 60)
					@warning = Warnings::CompanyClassBreak.new(@start_date)
				end
			
				it "#messages should be nil" do
					@warning.messages.should be_nil
				end
			end
		
			describe "and rehearsal within break period" do
				before do
					@rehearsal = FactoryGirl.create(:rehearsal, account: @account)
					@overlapping = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal,
								start_date: @start_date,
								start_time: '11:10 AM',
								duration: 60)
					@warning = Warnings::CompanyClassBreak.new(@start_date)
				end
			
				it "#messages should list warning messages" do
					messages = @warning.messages
				
					messages.size.should == 1
					msg = messages.first
				
					msg.include?("#{@company_class.title} ( 10:00 AM to 11:00 AM )").should be_true
					msg.include?("has the following rehearsals scheduled during the 15 minutes break:").should be_true
					msg.include?("#{@overlapping.title} ( 11:10 AM to 12:10 PM )").should be_true
				end
			end
		
			describe "and multiple classes with rehearsals within break period" do
				before do
					@rehearsal = FactoryGirl.create(:rehearsal, account: @account)
					@overlapping = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal,
								start_date: @start_date,
								start_time: '11:10 AM',
								duration: 60)
				
					@company_class2 = FactoryGirl.create(:company_class, :daily,
								account: @account,
								start_date: @start_date.to_s,
								end_date: @start_date.to_s,
								start_time: '1 PM',
								duration: 60)
					@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
					@overlapping2 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal2,
								start_date: @start_date,
								start_time: '2:10 PM',
								duration: 60)
					@warning = Warnings::CompanyClassBreak.new(@start_date)
				end
			
				it "#messages should list warning messages" do
					messages = @warning.messages
				
					messages.size.should == 2
					msg = messages.first
				
					msg.include?("#{@company_class.title} ( 10:00 AM to 11:00 AM )").should be_true
					msg.include?("has the following rehearsals scheduled during the 15 minutes break:").should be_true
					msg.include?("#{@overlapping.title} ( 11:10 AM to 12:10 PM )").should be_true
					
					msg = messages.last
					msg.include?("#{@company_class2.title} ( 1:00 PM to 2:00 PM )").should be_true
					msg.include?("has the following rehearsals scheduled during the 15 minutes break:").should be_true
					msg.include?("#{@overlapping2.title} ( 2:10 PM to 3:10 PM )").should be_true
				end
			end
		end
	end
end