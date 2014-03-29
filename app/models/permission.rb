class Permission
	def initialize(user)
		allow :static_pages, [:home, :features, :pricing, :contact]
		allow :sessions, [:new, :create, :destroy]
		allow :accounts, [:new, :create]
		
		if user
			allow :static_pages, [:dashboard]
			allow [:locations, :pieces, :scenes, :characters, :employees, :events], [:index]
			allow [:pieces, :events], [:show]
			
			if user.role == "Administrator"
				#index
				allow [:users, :seasons, :casts], [:index]
				
				#show
				allow [:accounts, :subscriptions, :agma_profiles, :employees, :seasons], 
						[:show]
				
				#new only
				allow [:casts], [:new]
				
				#new & create
				allow [:addresses, :phones, :employees, :users, :seasons, :locations, :pieces, 
						:scenes, :characters, :events, :rehearsals, :company_classes, :costume_fittings],
						[:new, :create]
				
				#edit & update
				allow [:accounts, :subscriptions, :payments, :agma_profiles, :addresses, 
						:phones, :employees, :users, :seasons, :locations, :pieces, :scenes, 
						:characters, :events, :rehearsals, :company_classes, :costume_fittings],
						[:edit, :update]
				
				#destroy
				allow [:subscriptions, :addresses, :phones, :seasons, :scenes, :characters, 
						:casts, :events, :rehearsals, :company_classes, :costume_fittings],
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
