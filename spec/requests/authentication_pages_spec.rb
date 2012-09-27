require 'spec_helper'

describe "Authentication" do
	context "for users who are NOT logged in" do
		context "Pieces" do
			let(:piece) { FactoryGirl.create(:piece) }
			
			describe "index is only available to signed in users" do
				pending
				#before { visit pieces_path }
				#specify { response.should redirect_to(login_path) }
			end
			
			describe "destroy is only available to signed in users" do
				pending
				#before { delete piece_path(FactoryGirl.create(:piece)) }
				#specify { response.should redirect_to(login_path) }
			end
			
			describe "new is only available to signed in users" do
				pending
				#before { visit new_piece_path }
				#specify { response.should redirect_to(login_path) }
			end
			
			describe "edit is only available to signed in users" do
				pending
				#before { visit edit_piece_path(piece) }
				#specify { response.should redirect_to(login_path) }
			end
		end
		
		context "Scenes " do
			describe "index is only available to signed in users" do
				pending
				#before { visit scenes_path }
				#specify { response.should redirect_to(login_path) }
			end
			
			describe "destroy is only available to signed in users" do
				pending
				#before { delete scene_path(FactoryGirl.create(:scene)) }
				#specify { response.should redirect_to(login_path) }
			end
			
			describe "new is only available to signed in users" do
				pending
				#before { visit new_scene_path }
				#specify { response.should redirect_to(login_path) }
			end
			
			describe "edit is only available to signed in users" do
				pending
				#before { visit edit_scene_path(scene) }
				#specify { response.should redirect_to(login_path) }
			end
			
			describe "show is only available to signed in users" do
				pending
				#before { visit scene_path(scene) }
				#specify { response.should redirect_to(login_path) }
			end
		end
		
		context "Roles " do
			describe "index is only available to signed in users" do
				pending
			end
			
			describe "destroy is only available to signed in users" do
				pending
			end
			
			describe "new is only available to signed in users" do
				pending
			end
			
			describe "edit is only available to signed in users" do
				pending
			end
		end
	end
end