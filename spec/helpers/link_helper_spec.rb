require 'spec_helper'

describe LinkHelper do
	context 'icon_link' do
		it "displays correct link" do
			html = icon_link("Text", "adjust", '#')
			html.should =~ /<a href="#">/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = icon_link("Text", "adjust", '#')
			html.should =~ /<span class="glyphicon glyphicon-adjust">/
			html.should =~ /<\/span>/
		end
		
		it "without text displays correct link" do
			html = icon_link(nil, "adjust", '#')
			html.should =~ /<\/span><\/a>/
		end
		
		it "with class set has correct HTML" do
			html = icon_link(nil, "adjust", '#', class: 'my-class')
			html.should =~ /class="my-class"/
		end
	end
	
	context 'new_link' do
		it "displays correct link" do
			html = new_link("Text", '#')
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = new_link("Text", '#')
			html.should =~ /<span class="glyphicon glyphicon-plus mash-green">/
			html.should =~ /<\/span>/
		end
		
		it "has default tooltip of 'Add'" do
			html = new_link(nil, '#')
			html.should =~ /title="Add"/
		end
		
		it "with title option displays correct tooltip" do
			html = new_link(nil, '#', title:'my-title')
			html.should =~ /title="my-title"/
		end
		
		it "without text displays correct link" do
			html = new_link(nil, '#')
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'edit_link' do
		it "displays correct link" do
			html = edit_link("Text", '#')
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = edit_link("Text", '#')
			html.should =~ /<span class="glyphicon glyphicon-pencil mash-grey">/
			html.should =~ /<\/span>/
		end
		
		it "has default tooltip of 'Edit'" do
			html = edit_link(nil, '#')
			html.should =~ /title="Edit"/
		end
		
		it "with title option displays correct tooltip" do
			html = edit_link(nil, '#', title:'my-title')
			html.should =~ /title="my-title"/
		end
		
		it "without text displays correct link" do
			html = edit_link(nil, '#')
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'delete_link' do
		it "displays correct link" do
			html = delete_link("Text", '#')
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = delete_link("Text", '#')
			html.should =~ /<span class="glyphicon glyphicon-minus-sign mash-red">/
			html.should =~ /<\/span>/
		end
		
		it "has default tooltip of 'Delete'" do
			html = delete_link(nil, '#')
			html.should =~ /title="Delete"/
		end
		
		it "with title option displays correct tooltip" do
			html = delete_link(nil, '#', title:'my-title')
			html.should =~ /title="my-title"/
		end
		
		it "has delete method" do
			html = delete_link(nil, '#')
			html.should =~ /data-method="delete"/
		end
		
		it "has data confirmation message of 'Delete?'" do
			html = delete_link(nil, '#')
			html.should =~ /data-confirm=/
			html.should =~ /Delete?/
		end
		
		it "without text displays correct link" do
			html = delete_link(nil, '#')
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'view_link' do
		it "displays correct link" do
			html = view_link("Text", '#')
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = view_link("Text", '#')
			html.should =~ /<span class="glyphicon glyphicon-info-sign">/
			html.should =~ /<\/span>/
		end
		
		it "has default tooltip of 'View'" do
			html = view_link('Text', '#')
			html.should =~ /title="View"/
		end
		
		it "with title option displays correct tooltip" do
			html = view_link(nil, '#', title:'my-title')
			html.should =~ /title="my-title"/
		end
		
		it "without text displays correct link" do
			html = view_link(nil, '#')
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'pdf_link' do
		it "displays correct link" do
			html = pdf_link("Text", "#")
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = pdf_link("Text", "#")
			html.should =~ /<span class=\"glyphicon glyphicon-download\"><\/span>/
		end
		
		it "without text displays correct link" do
			html = pdf_link(nil, "#")
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'new_button' do
		it "is a normal button" do
			html = new_button("Text", '#')
			html.should =~ /btn btn-default/
		end
		
		it "displays correct link" do
			html = new_button("Text", '#')
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = new_button("Text", '#')
			html.should =~ /<span class="glyphicon glyphicon-plus mash-green">/
			html.should =~ /<\/span>/
		end
		
		it "has tooltip of 'Add'" do
			html = new_button(nil, '#')
			html.should =~ /title="Add"/
		end
		
		it "without text displays correct link" do
			html = new_button(nil, '#')
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'edit_button' do
		it "is a button" do
			html = edit_button("Text", '#')
			html.should =~ /btn btn-default/
		end
		
		it "displays correct link" do
			html = edit_button("Text", '#')
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = edit_button("Text", '#')
			html.should =~ /<span class="glyphicon glyphicon-pencil mash-grey">/
			html.should =~ /<\/span>/
		end
		
		it "has tooltip of 'Edit'" do
			html = edit_button(nil, '#')
			html.should =~ /title="Edit"/
		end
		
		it "without text displays correct link" do
			html = edit_button(nil, '#')
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'delete_button' do
		it "is a red button" do
			html = delete_button("Text", '#')
			html.should =~ /btn btn-danger/
		end
		
		it "displays correct link" do
			html = delete_button("Text", '#')
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = delete_button("Text", '#')
			html.should =~ /<span class="glyphicon glyphicon-trash">/
			html.should =~ /<\/span>/
		end
		
		it "has tooltip of 'Delete'" do
			html = delete_button(nil, '#')
			html.should =~ /title="Delete"/
		end
		
		it "has delete method" do
			html = delete_button(nil, '#')
			html.should =~ /data-method="delete"/
		end
		
		it "has data confirmation message of 'Delete?'" do
			html = delete_button(nil, '#')
			html.should =~ /data-confirm=/
			html.should =~ /Delete?/
		end
		
		it "without text displays correct link" do
			html = delete_link(nil, '#')
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'view_button' do
		it "is a button" do
			html = view_button("Text", '#')
			html.should =~ /btn btn-default/
		end
		
		it "displays correct link" do
			html = view_button("Text", '#')
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = view_button("Text", '#')
			html.should =~ /<span class="glyphicon glyphicon-info-sign">/
			html.should =~ /<\/span>/
		end
		
		it "has tooltip of 'View'" do
			html = view_button('Text', '#')
			html.should =~ /title="View"/
		end
		
		it "without text displays correct link" do
			html = view_button(nil, '#')
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'activate_button' do
		it "is a green button" do
			html = activate_button("Text", '#')
			html.should =~ /btn btn-success/
		end
		
		it "displays correct link" do
			html = activate_button("Text", '#')
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = activate_button("Text", '#')
			html.should =~ /<span class="glyphicon glyphicon-thumbs-up">/
			html.should =~ /<\/span>/
		end
		
		it "has tooltip of 'Activate'" do
			html = activate_button('Text', '#')
			html.should =~ /title="Activate"/
		end
		
		it "without text displays correct link" do
			html = activate_button(nil, '#')
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'inactivate_button' do
		it "is a yellow button" do
			html = inactivate_button("Text", '#')
			html.should =~ /btn btn-warning/
		end
		
		it "displays correct link" do
			html = inactivate_button("Text", '#')
			html.should =~ /<a href="#"/
			html.should =~ /Text<\/a>/
		end
		
		it "displays correct icon" do
			html = inactivate_button("Text", '#')
			html.should =~ /<span class="glyphicon glyphicon-thumbs-down">/
			html.should =~ /<\/span>/
		end
		
		it "has tooltip of 'Inactivate'" do
			html = inactivate_button('Text', '#')
			html.should =~ /title="Inactivate"/
		end
		
		it "without text displays correct link" do
			html = inactivate_button(nil, '#')
			html.should =~ /<\/span><\/a>/
		end
	end
	
	context 'gear_dropdown' do
		before { @html = gear_dropdown { 'AZdS' } }
			
		it "displays a dropdown" do
			@html.should =~ /dropdown-toggle/
		end
		
		it "displays correct icon" do
			@html.should =~ /<span class="glyphicon glyphicon-cog"/
			@html.should =~ /<\/span>/
		end
		
		it "has tooltip of 'Tools'" do
			@html.should =~ /title="Tools"/
		end
		
		it "displays the block text" do
			@html.should =~ /AZdS/
		end
	end
end