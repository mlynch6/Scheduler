Scheduler::Application.routes.draw do
  root :to => 'static_pages#home'
	match 'login' => 'sessions#new'
	match 'logout' =>'sessions#destroy'
	match 'signup' => 'accounts#new'
	get 'dashboard', to: 'dashboards#index'
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
	
  resources :events
  resources :company_classes,		:except => [:index, :show], 	:controller => :events, :event_type => 'CompanyClass'
  get 'events/:year/:month/:day', to: 'events#index'
	
	match 'features' => 'static_pages#features'
	match 'pricing' => 'static_pages#pricing'
	match 'contact' => 'static_pages#contact'
	
	match 'subscriptions/current' => 'subscriptions#show'
	match 'subscriptions/edit' => 'subscriptions#edit'
	match 'subscriptions/update' => 'subscriptions#update'
	match 'subscriptions/cancel' => 'subscriptions#destroy'
	
	match 'payments/edit' => 'payments#edit'
	match 'payments/update' => 'payments#update'
	
	namespace :company do
		namespace :contract do
			match 'rehearsal_week', 		to: 'rehearsal_week#show', 	:via => :get
			match 'company_class', 			to: 'company_class#show', 	:via => :get
			match 'costume_fitting', 		to: 'costume_fitting#show',	:via => :get
			match 'lecture_demo', 			to: 'lecture_demo#show', 		:via => :get
			
			match 'rehearsal_week/edit', 	to: 'rehearsal_week#edit', 			:via => :get
			match 'rehearsal_week', 			to: 'rehearsal_week#update', 		:via => :put
			match 'company_class/edit', 	to: 'company_class#edit', 			:via => :get
			match 'company_class', 				to: 'company_class#update', 		:via => :put
			match 'costume_fitting/edit', to: 'costume_fitting#edit', 		:via => :get
			match 'costume_fitting', 			to: 'costume_fitting#update', 	:via => :put
			match 'lecture_demo/edit', 		to: 'lecture_demo#edit', 				:via => :get
			match 'lecture_demo', 				to: 'lecture_demo#update', 			:via => :put
			
			resources :rehearsal_breaks, 	:only => [:new, :create, :destroy]
		end
		resources :publish_casts,				:only => [:update]
	end
	
	namespace :schedule do
		resources :rehearsals,				:except => [:show]
		match 'rehearsals/scenes_by_piece' => 'rehearsals#scenes_by_piece',	:via => :post
		resources :costume_fittings,	:except => [:show]
		resources :lecture_demos,			:except => [:show]
	end
	
	namespace :admin do
		resources :accounts,						:only => [:index, :edit, :update, :destroy]
		resources :subscription_plans,	:except => [:show]
		resources :dropdowns,						:except => [:show] do
			collection { post :sort }
		end
	end
end
