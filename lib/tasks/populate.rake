namespace :db do
	desc "Erase and fill database"
	task :populate => :environment do
		require 'populator'
		
		[Account, Employee, User, Location].each(&:delete_all)
		
		Account.populate 15 do |account|
			account.name = Faker::Company.name
			account.main_phone = Faker::PhoneNumber.phone_number
			account.time_zone = ["Eastern Time (US & Canada)", "Central Time (US & Canada)", "Mountain Time (US & Canada)", "Pacific Time (US & Canada)"]
			account.created_at = 2.years.ago..Time.now
			
			Employee.populate 5..20 do |employee|
				employee.account_id = account.id
				employee.first_name = Faker::Name.first_name
				employee.last_name = Faker::Name.last_name
				employee.active = [true, false]
				employee.job_title = Faker::Name.title
				employee.email = Faker::Internet.free_email
				employee.phone = Faker::PhoneNumber.phone_number
				employee.created_at = 2.years.ago..Time.now

				User.populate 0..1 do |user|
					user.employee_id = employee.id
					user.username = Faker::Internet.user_name(employee.first_name+" "+employee.last_name)
					#All user's Passwords = password
					user.password_digest = "$2a$10$DwzOZBQY5I28pP14ZmAqlue3NM44cMByoVnWDFI9klMqvtGmKbHt2"
					user.role = ["Employee", "Administrator"]
					user.created_at = 2.years.ago..Time.now
				end
			end
			
			Location.populate 1..5 do |location|
				location.account_id = account.id
				location.name = Populator.words(1..2).titleize
				location.active = [true, false]
				location.created_at = 2.years.ago..Time.now
			end
		end
		
		#create Super Admin account
		Employee.populate 1 do |employee|
			employee.account_id = 1
			employee.first_name = "Melody"
			employee.last_name = "Stephen-Hassard"
			employee.active = true
			employee.job_title = "Super Admin"
			employee.email = "mlynch6@hotmail.com"
			employee.phone = "617-852-3793"

			User.populate 1 do |user|
				user.employee_id = employee.id
				user.username = "mlynch6"
				user.password_digest = "$2a$10$DwzOZBQY5I28pP14ZmAqlue3NM44cMByoVnWDFI9klMqvtGmKbHt2"
				user.role = "Super Administrator"
			end
		end
	end
end