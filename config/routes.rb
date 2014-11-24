Scheduler::Application.routes.draw do
  root :to => 'static_pages#home'
	match 'login' => 'sessions#new'
	match 'logout' =>'sessions#destroy'
	match 'signup' => 'accounts#new'
	resource :dashboard,					:only => [:show]
	resources :password_resets,		:except => [:show, :destroy]
	
	resources :accounts do
		resources :addresses, 			:except => [:index, :show]
		resources :phones, 					:except => [:index, :show]
	end
  resources :sessions
	resources :passwords,					:only => [:new, :create]
  
  resources :employees do
  	member do
  		get 'activate'
  		get 'inactivate'
  	end
		resource :employment, 			:only => [:show, :edit, :update]
		resource :biography, 				:only => [:show, :edit, :update]
  end
	resources :people, 						:only => [] do
		resources :addresses, 			:except => [:index, :show]
		resources :phones, 					:except => [:index, :show]
		resources :users, 					:only => [:new, :create]
	end
	resources :users, 						:only => [:index, :edit, :update, :destroy]
	match 'users/:id/permissions', 	to: 'users#edit', :via => :get, :as => :edit_permissions
  
  resources :locations, 				:except => [:show] do
  	member do
  		get 'activate'
  		get 'inactivate'
  	end
  end
  
  resources :seasons
  resources :pieces do
		resources :scenes, :characters, :only => [:index, :new, :create]
  end
  resources :scenes, :characters, 	:only => [:edit, :update, :destroy] do
		collection { post :sort }
  end
  resources :season_pieces, 	:only => [] do
		resources :casts,					:only => [:index, :show, :new]
  end
  resources :casts,						:only => [:destroy]
	resources :castings,				:only => [:edit, :update]
	
	match 'features' => 'static_pages#features'
	match 'pricing' => 'static_pages#pricing'
	match 'contact' => 'static_pages#contact'
	
	resource :subscriptions, 					:only => [:show, :edit, :update, :destroy]
	resource :payments, 							:only => [:edit, :update]
	
	namespace :company do
		namespace :contract do	
			resource :rehearsal_week, 		:only => [:show, :edit, :update]
			resources :rehearsal_breaks, 	:only => [:new, :create, :destroy]
			resource :company_class, 			:only => [:show, :edit, :update]
			resource :costume_fitting, 		:only => [:show, :edit, :update]
			resource :lecture_demo, 			:only => [:show, :edit, :update]
		end
		resources :publish_casts,				:only => [:update]
	end
	
	namespace :schedule do
		resources :company_classes do
			get :dates, :on => :member
		end
		resources :rehearsals do
			post :scenes_by_piece, :on => :collection
		end
		resources :costume_fittings
		resources :lecture_demos
	  resources :events,						:except => [:new, :create] do
			resources :invitees, 				:only => [:index, :new, :create], :path_names => { :new => 'change' }
		end
	  match 'events/:year/:month/:day', to: 'events#index', :via => :get
		resources :selected_events,		:only => [:create]
	end
	
	namespace :current do
		resources :season,							:only => [:new, :create]
	end
	
	namespace :reports do
		resource :warning, 							:only => [:show]
	end
	
	namespace :admin do
		resources :accounts,						:only => [:index, :edit, :update, :destroy]
		resources :subscription_plans,	:except => [:show]
		resources :dropdowns,						:except => [:show] do
			collection { post :sort }
		end
	end
end
