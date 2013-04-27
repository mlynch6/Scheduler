class Permission
	def initialize(user)
		allow :static_pages, [:home, :features, :pricing, :contact]
		allow :sessions, [:new, :create, :destroy]
		allow :accounts, [:new, :create]
		
		if user
			allow :static_pages, [:dashboard]
			allow [:locations, :pieces, :scenes, :characters, :employees, :events], [:index]
			allow [:rehearsals, :company_classes], [:show]
			
			if user.role == "Administrator"
				#index
				allow [:users], [:index]
				
				#show
				allow [:accounts, :agma_profiles, :employees], [:show]
				
				#new & create
				allow [:addresses, :employees, :users, :locations, :pieces, :scenes, :characters, :rehearsals, :company_classes], [:new, :create]
				
				#edit & update
				allow [:accounts, :agma_profiles, :addresses, :employees, :users, :locations, :pieces, :scenes, :characters, :rehearsals, :company_classes], [:edit, :update]
				
				#destroy
				allow [:addresses, :scenes, :characters], [:destroy]
				
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
