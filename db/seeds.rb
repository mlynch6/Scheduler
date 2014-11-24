#Add Subscription Plans used by Stripe
subscription_plans = [
	[ "Beta", 0 ],
	[ "Dance Company", 15 ]
]
subscription_plans.each do |plan|
  SubscriptionPlan.find_or_create_by_name(:name => plan[0], :amount => plan[1])
end

#Add User Roles used by CanCan
user_roles = [
	[ "Administrator", "Allows the user to manage all aspects of the system." ],
	[ "Manage Employees", "Allows the user to view, add, edit, activate or deactivate an Employee.
				Allows the user to manage the Employee's Address and Phone Numbers." ],
	[ "Manage Logins", "Allows the user to view Employees.
				Allows the user to view, add, edit, or delete the Employee's Username/Password." ],
	[ "Manage Locations", "Allows the user to view, add, edit, or delete a Location." ],
	[ "Manage Seasons", "Allows the user to view, add, edit, or delete a Season." ],
	[ "Manage Pieces", "Allows the user to view, add, edit, or delete a Piece.
				Allows the user to manage the Piece's Scenes and Characters." ],
	[ "Manage AGMA Contract", "Allows the user to view or update the AGMA Contract settings.
				Allows the user to manage settings related to Rehearsal Weeks, Company Classes, Costume Fittings, and Lecture Demos." ],
	[ "Schedule Company Classes", "Allows the user to view, add, edit, or delete a Company Class." ],
	[ "Schedule Costume Fittings", "Allows the user to view, add, edit, or delete a Costume Fitting." ],
	[ "Schedule Rehearsals", "Allows the user to view, add, edit, or delete a Rehearsal." ],
	[ "Schedule Lecture Demos", "Allows the user to view, add, edit, or delete a Lecture Demonstration." ],
	[ "Manage Casts", "Allows the user to view Seasons and Pieces.
				Allows the user to view, add, or delete a Cast.
				Allows the user to cast artists to Characters in a Piece.
				Allows the user to publish the Casting for other users to view." ],
	[ "Manage Account", "Allows the user to view and update their Account.
				Allows the user to manage their Account's Address and Phone Numbers.
				Allows the user to view or update their Payment Method.
				Allows the user to view, update, or cancel their Subscription." ]
]
user_roles.each do |role|
  Dropdown.of_type('UserRole').find_or_create_by_name(:name => role[0], :comment => role[1])
end