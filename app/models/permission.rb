class Permission
	def initialize(user)
		allow :static_pages, [:home, :features, :pricing, :contact]
		allow :sessions, [:new, :create, :destroy]
		allow :accounts, [:new, :create]
		allow :password_resets, [:index, :new, :create, :edit, :update]
		
		if user
			allow [:dashboards, :locations, :pieces, :scenes, :characters, :employees, :events], [:index]
			allow [:pieces, :events], [:show]
			
			if user.role == "Administrator"
				#index
				allow [:users, :seasons, :casts], [:index]
				
				#show
				allow [:accounts, :subscriptions, :agma_contracts, :employees, :seasons, :casts], 
						[:show]
				
				#new only
				allow [:casts], [:new]
				
				#new & create
				allow [:addresses, :phones, :employees, :users, :seasons, :locations, :pieces, 
						:scenes, :characters, :events, :rehearsals, :company_classes, :costume_fittings,
						:rehearsal_breaks],
						[:new, :create]
				
				#edit & update
				allow [:accounts, :subscriptions, :payments, :agma_contracts, :addresses, 
						:phones, :employees, :users, :seasons, :locations, :pieces, :scenes, 
						:characters, :events, :rehearsals, :company_classes, :costume_fittings,
						:castings],
						[:edit, :update]
				
				#update
				allow [:publish_casts], [:update]
				
				#destroy
				allow [:subscriptions, :addresses, :phones, :seasons, :scenes, :characters, 
						:casts, :events, :rehearsals, :company_classes, :costume_fittings, :rehearsal_breaks],
						[:destroy]
				
				#activate & inactivate
				allow [:employees, :locations], [:activate, :inactivate]
				
				#inactive
				allow [:employees], [:inactive]
				
				#sort
				allow [:scenes, :characters], [:sort]
			end
			
			allow_all if user.role == "Super Administrator"
		end
	end
	
	def allow?(controller, action)
		@allow_all || @allowed_actions[[controller.to_s, action.to_s]]
	end
	
	def allow_all
		@allow_all = true
	end
	
	def allow(controllers, actions)
		@allowed_actions ||= {}
		Array(controllers).each do |controller|
			Array(actions).each do |action|
				@allowed_actions[[controller.to_s, action.to_s]] = true
			end
		end
	end
end
