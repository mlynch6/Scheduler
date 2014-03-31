namespace :db do
	desc "Delete & Fill database with Milwaukee Ballet information"
	task :populate_milwaukee => :environment do
		
		#clear DB
		Account.unscoped.delete_all
		AgmaContract.unscoped.delete_all
		Employee.unscoped.delete_all
		User.unscoped.delete_all
		Address.unscoped.delete_all
		Phone.unscoped.delete_all
		Location.unscoped.delete_all
		Season.unscoped.delete_all
		Piece.unscoped.delete_all
		SeasonPiece.unscoped.delete_all
		Event.unscoped.delete_all
		Invitation.unscoped.delete_all
		Scene.unscoped.delete_all
		Character.unscoped.delete_all
		Appearance.unscoped.delete_all
		Cast.unscoped.delete_all
		
		a = Account.create(
			name: 'Milwaukee Ballet [Dev]',
			time_zone: "Eastern Time (US & Canada)",
			current_subscription_plan_id: 1
			)
		#Create Stripe customer
		token = Stripe::Token.create(:card => { :number => "4242424242424242", :exp_month => 7, :exp_year => Date.today.year+1, :cvc => 314 })
		a.stripe_card_token = token.id
		a.save_with_payment
		Account.current_id = a.id
		
		contract = a.agma_contract
		contract.rehearsal_start_min = 570		# 9:30 AM
		contract.rehearsal_end_min = 1710		# 6:30 PM
		contract.rehearsal_max_hrs_per_week = 30
		contract.rehearsal_max_hrs_per_day = 6
		contract.rehearsal_increment_min = 30
		contract.class_break_min = 15
		contract.rehearsal_break_min_per_hr = 5
		contract.costume_increment_min = 15
		contract.save
		
		a.addresses.create(
			addr_type: "Work",
			addr: "504 W National Ave",
			city: "Milwaukee",
			state: "WI",
			zipcode: "53204"
			)
		a.phones.create(
			phone_type: 'Work',
			phone_num: '414-643-7677',
			primary: true
			)

		#create Super Admin account
		e = Employee.create(
			first_name: "Melody",
			last_name: "Stephen-Hassard",
			active: true,
			role: "Artistic Director",
			email: "mlynch6@hotmail.com",
			)
		e.phones.create(phone_type: 'Cell', phone_num: "617-852-3793")
		u = e.create_user(
			username: "mlynch6",
			password: "password",
			password_confirmation: "password"
			)
		u.update_attribute(:role, 'Super Administrator')
			
		#create Administrator account
		e = Employee.create(
			first_name: "Administrator",
			last_name: "Tester",
			active: true,
			role: "Ballet Master",
			email: "admin@example.com"
			)
		u = e.create_user(
			username: "testadmin",
			password: "password",
			password_confirmation: "password"
			)
		u.set_admin_role

		#create Employee account
		e = Employee.create(
			first_name: 'Employee',
			last_name: 'Tester',
			active: true,
			role: "Employee",
			email: "employee@example.com"
			)
		e.create_user(
			username: "testemp",
			password: "password",
			password_confirmation: "password"
			)

		Employee.create(first_name: 'Michael', last_name: 'Pink', role: "Artistic Director")
		Employee.create(first_name: 'Nadia', last_name: 'Thompson', role: "Ballet Master")
		Employee.create(first_name: 'Denis', last_name: 'Malinkine', role: "Ballet Master")
		Employee.create(first_name: 'Douglas', last_name: 'McCubbin', role: "Employee")
		Employee.create(first_name: 'Luz', last_name: 'San Miguel', role: "AGMA Dancer")
		Employee.create(first_name: 'Marc', last_name: 'Petrocci', role: "AGMA Dancer")
		Employee.create(first_name: 'Kara', last_name: 'Bruzina', role: "AGMA Dancer")
		Employee.create(first_name: 'Susan', last_name: 'Gartell', role: "AGMA Dancer")
		Employee.create(first_name: 'Erik', last_name: 'Johnson', role: "AGMA Dancer")
		Employee.create(first_name: 'Courtney', last_name: 'Kramer', role: "AGMA Dancer")
		Employee.create(first_name: 'Timothy', last_name: "O'Donnell", role: "AGMA Dancer")
		Employee.create(first_name: 'Nicole', last_name: 'Teague', role: "AGMA Dancer")
		Employee.create(first_name: 'Tina', last_name: 'Ohr', role: "Musician")
		Employee.create(first_name: 'Amanda', last_name: 'Rice', role: "Musician")

		locations = ['Studio A', 'Studio B', 'Studio C', 'Studio D', 'Wardrobe', 'Theatre']
		locations.each do |loc|
			Location.create(name: loc)
		end
		
		Season.create(name: '2010-2011 Season', start_dt: '8/1/2010', end_dt: '5/30/2011')
		Season.create(name: '2011-2012 Season', start_dt: '8/1/2011', end_dt: '5/30/2012')
		s2012 = Season.create(name: '2012-2013 Season', start_dt: '8/1/2012', end_dt: '5/30/2013')
		s2013 = Season.create(name: '2013-2014 Season', start_dt: '8/1/2013', end_dt: '5/30/2014')

		#Pieces for 2012-2013 Season
		pieces = ['La Boheme', 'Nutcracker', 'Manifold', 'I Hit the Ground', 'Simply Sammy', 'Mozart Requiem', 'Children of the Wall', 'Swan Lake']
		pieces.each do |piece|
			s2012.pieces.create(name: piece)
		end
		
		#Pieces for 2013-2014 Season
		pieces = ['Romeo & Juliet', 'Nutcracker', 'Our Waltzes', 'Mirror Mirror']
		pieces.each do |piece|
			s2013.pieces.create(name: piece)
		end
		
		pieces = ['Peter Pan', 'Who Cares']
		pieces.each do |piece|
			Piece.create(name: piece)
		end
		
		pan = Piece.find_by_name('Peter Pan')
		scenes = ['Overture', 'Prologue: Kensington Gardens', 'Scene 1: Bloomsbury', 'Tinker Bell', "Pan's Entrance", 'The Chase', 'Nocturne 1', 'Scene 2: Bloomsbury']
		scenes.each do |name|
			pan.scenes.create(name: name)
		end
		
		characters = ['Peter Pan', 'Wendy Darling', 'Mary Darling', 'Tiger Lily', 'George Darling', 'Captain James Hook', 'Tinker Bell', 'John Darling', 'Michael Darling']
		characters.each do |name|
			pan.characters.create(name: name)
		end
	end
end