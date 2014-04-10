require 'spec_helper'

describe "Rehearsal Break Pages:" do
	subject { page }
	
	before do
		log_in
		@break60 = FactoryGirl.create(:rehearsal_break, 
							agma_contract: current_account.agma_contract,
							duration_min: 60,
							break_min: 5)
		
		click_link "Setup"
		click_link "Contract Settings"
		click_link "Rehearsal Week"
	end

	context "#new" do
		before do
			click_link 'Add Rehearsal Break'
		end
		
		it "has correct title" do
			should have_title 'Contract Settings | Add Rehearsal Break'
			should have_selector 'h1', text: 'Add Rehearsal Break'
		end

		it "has correct Navigation" do
			should have_selector('li.active', text: 'Setup')
			should have_selector('li.active', text: 'Contract Settings')
		end

		it "has correct fields on form" do
			should have_field 'Rehearsal Length'
			should have_field 'Break Length'
		end

		context "with error" do
			it "shows error message" do
				click_button 'Create'

				should have_selector('div.alert-danger')
			end

			it "doesn't create record" do
				expect { click_button 'Create' }.not_to change(RehearsalBreak, :count)
			end
		end

		context "with valid info" do
			it "creates new record" do
				fill_in "Rehearsal Length", with: 90
				fill_in "Break Length", with: 10
				click_button 'Create'

				should have_selector 'div.alert-success'
				should have_title 'Contract Settings'
				should have_selector 'td', text: '90 min rehearsal'
				should have_selector 'td', text: '10 min break'
			end
		end
	end

	describe "#destroy" do
		it "deletes the record" do
			click_link "delete_#{@break60.id}"

			should have_selector 'div.alert-success'
			should have_title 'Contract Settings'

			should_not have_selector 'td', text: '60 min rehearsal'
			should_not have_selector 'td', text: '5 min break'
		end
	end
end
