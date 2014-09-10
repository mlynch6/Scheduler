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
	[ "manage_logins", "Allows the user to view Employees.
				Allows the user to view, add, edit, or delete the Employee's Username/Password." ],
	[ "manage_locations", "Allows the user to view, add, edit, or delete a Location." ],
	[ "manage_seasons", "Allows the user to view, add, edit, or delete a Season." ],
	[ "manage_pieces", "Allows the user to view, add, edit, or delete a Piece.
				Allows the user to manage the Piece's Scenes and Characters." ],
	[ "manage_agma_contract", "Allows the user to view or update the AGMA Contract settings." ],
	[ "schedule_company_classes", "Allows the user to view, add, edit, or delete a Company Class." ],
	[ "schedule_costume_fittings", "Allows the user to view, add, edit, or delete a Costume Fitting." ],
	[ "schedule_rehearsals", "Allows the user to view, add, edit, or delete a Rehearsal." ],
	[ "manage_casts", "Allows the user to view Seasons and Pieces.
				Allows the user to view, add, or delete a Cast.
				Allows the user to cast artists to Characters in a Piece.
				Allows the user to publish the Casting for other users to view." ]
]
Dropdown.of_type('UserRole').each do |role|
  Dropdown.find_or_create_by_name(:name => role[0], :cooment => role[1])
end