require 'spec_helper'

describe LinkHelper do
	context "Links with text:" do
		it "new_link displays correct HTML" do
			new_link("Test", "#").should == '<a href="#"><i class="icon-plus"></i> Test</a>'
		end
	
		it "edit_link displays correct HTML" do
			edit_link("Test", "#").should == '<a href="#"><i class="icon-pencil"></i> Test</a>'
		end
		
		it "delete_link displays correct HTML" do
			delete_link("Test", "#").should == '<a href="#" data-confirm="Delete?" data-method="delete" rel="nofollow"><i class="icon-trash"></i> Test</a>'
		end
		
		it "pdf_link displays correct HTML" do
			pdf_link("Test", "#").should == '<a href="#"><img alt="File_extension_pdf" src="/images/file_extension_pdf.png" /> Test</a>'
		end
		
		it "view_link displays correct HTML" do
			view_link("Test", "#").should == '<a href="#"><i class="icon-info-sign"></i> Test</a>'
		end
		
		it "excel_link displays correct HTML" do
			excel_link("Test", "#").should == '<a href="#"><img alt="File_extension_xls" src="/images/file_extension_xls.png" /> Test</a>'
		end
	end
	
	context "Links without text:" do
		it "new_link displays correct tooltip" do
			new_link(nil, "#").should == '<a href="#" title="Add"><i class="icon-plus"></i></a>'
		end
	
		it "edit_link displays correct tooltip" do
			edit_link(nil, "#").should == '<a href="#" title="Edit"><i class="icon-pencil"></i></a>'
		end
		
		it "delete_link displays correct tooltip" do
			delete_link(nil, "#").should == '<a href="#" data-confirm="Delete?" data-method="delete" rel="nofollow" title="Delete"><i class="icon-trash"></i></a>'
		end
		
		it "view_link displays correct HTML" do
			view_link(nil, "#").should == '<a href="#" title="View"><i class="icon-info-sign"></i></a>'
		end
	end
	
	context "Buttons with text:" do
		it "new_button displays correct HTML" do
			new_button("Test", "#").should == '<a href="#" class="btn"><i class="icon-plus"></i> Test</a>'
		end
	
		it "edit_button displays correct HTML" do
			edit_button("Test", "#").should == '<a href="#" class="btn"><i class="icon-pencil"></i> Test</a>'
		end
		
		it "delete_button displays correct HTML" do
			delete_button("Test", "#").should == '<a href="#" class="btn btn-danger" data-confirm="Delete?" data-method="delete" rel="nofollow"><i class="icon-trash"></i> Test</a>'
		end
		
		it "view_button displays correct HTML" do
			view_button("Test", "#").should == '<a href="#" class="btn btn-info"><i class="icon-info-sign"></i> Test</a>'
		end
		
		it "activate_button displays correct HTML" do
			activate_button("Test", "#").should == '<a href="#" class="btn btn-success"><i class="icon-thumbs-up"></i> Test</a>'
		end
		
		it "inactivate_button displays correct HTML" do
			inactivate_button("Test", "#").should == '<a href="#" class="btn btn-warning"><i class="icon-thumbs-down"></i> Test</a>'
		end
	end
	
	context "Buttons without text:" do
		it "new_button displays correct tooltip" do
			new_button(nil, "#").should == '<a href="#" class="btn" title="Add"><i class="icon-plus"></i></a>'
		end
	
		it "edit_button displays correct tooltip" do
			edit_button(nil, "#").should == '<a href="#" class="btn" title="Edit"><i class="icon-pencil"></i></a>'
		end
		
		it "delete_button displays correct tooltip" do
			delete_button(nil, "#").should == '<a href="#" class="btn btn-danger" data-confirm="Delete?" data-method="delete" rel="nofollow" title="Delete"><i class="icon-trash"></i></a>'
		end
		
		it "view_button displays correct tooltip" do
			view_button(nil, "#").should == '<a href="#" class="btn btn-info" title="View"><i class="icon-info-sign"></i></a>'
		end
		
		it "activate_button displays correct tooltip" do
			activate_button(nil, "#").should == '<a href="#" class="btn btn-success" title="Activate"><i class="icon-thumbs-up"></i></a>'
		end
		
		it "inactivate_button displays correct tooltip" do
			inactivate_button(nil, "#").should == '<a href="#" class="btn btn-warning" title="Inactivate"><i class="icon-thumbs-down"></i></a>'
		end
	end
end