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
	resources :agma_contracts, 		:only => [:show, :edit, :update] do
		resources :rehearsal_breaks, :only => [:new, :create]
	end
	resources :rehearsal_breaks, 	:only => [:destroy]
  resources :sessions
  resources :users, 						:only => [:index, :new, :create, :destroy]
	resources :passwords,					:only => [:new, :create]
  
  resources :employees do
  	get 'inactive', on: :collection
  	member do
  		get 'activate'
  		get 'inactivate'
  	end
  end
	resources :people, 						:only => [] do
		resources :addresses, 			:except => [:index, :show]
		resources :phones, 					:except => [:index, :show]
	end
  
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
  resources :costume_fittings,	:except => [:index, :show], :controller => :events, :event_type => 'CostumeFitting'
  resources :rehearsals,				:except => [:index, :show], :controller => :events, :event_type => 'Rehearsal'
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
		resources :publish_casts,				:only => [:update]
	end
	
	namespace :admin do
		resources :accounts,						:only => [:index, :edit, :update, :destroy]
		resources :subscription_plans,	:except => [:show]
		resources :dropdowns,						:except => [:show] do
			collection { post :sort }
		end
	end
end
