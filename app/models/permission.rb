class Permission
	def initialize(user)
		allow :static_pages, [:home, :features, :pricing, :contact]
		allow :sessions, [:new, :create, :destroy]
		allow :accounts, [:new, :create]
		
		if user
			allow :static_pages, [:dashboard]
			allow [:locations, :pieces, :employees, :events], [:index]
			allow [:rehearsals, :company_classes], [:show]
			
			if user.role == "Administrator"
				allow [:accounts], [:edit, :update, :show]
				allow [:accounts, :agma_profiles], [:edit, :update]
				allow [:locations, :pieces, :employees], [:new, :create, :edit, :update, :inactive, :activate, :inactivate]
				allow [:rehearsals, :company_classes], [:new, :create]
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
