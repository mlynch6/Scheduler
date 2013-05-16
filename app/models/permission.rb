class Permission
	def initialize(user)
		allow :static_pages, [:home, :features, :pricing, :contact]
		allow :sessions, [:new, :create, :destroy]
		allow :accounts, [:new, :create]
		
		if user
			allow :static_pages, [:dashboard]
			allow [:locations, :pieces, :scenes, :characters, :employees, :events], [:index]
			
			if user.role == "Administrator"
				#index
				allow [:users, :seasons], [:index]
				
				#show
				allow [:accounts, :agma_profiles, :employees], [:show]
				
				#new & create
				allow [:addresses, :phones, :employees, :users, :seasons, :locations, :pieces, :scenes, :characters, :rehearsals, :company_classes, :costume_fittings], [:new, :create]
				
				#edit & update
				allow [:accounts, :agma_profiles, :addresses, :phones, :employees, :users, :seasons, :locations, :pieces, :scenes, :characters, :rehearsals, :company_classes, :costume_fittings], [:edit, :update]
				
				#destroy
				allow [:addresses, :phones, :seasons, :scenes, :characters], [:destroy]
				
				#activate & inactive & inactivate
				allow [:employees, :locations, :pieces], [:inactive, :activate, :inactivate]
				
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
