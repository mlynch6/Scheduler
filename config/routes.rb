Scheduler::Application.routes.draw do
  root :to => 'static_pages#home'
	match 'login' => 'sessions#new'
	match 'logout' =>'sessions#destroy'
	match 'signup' => 'accounts#new'
	
	resources :accounts
	resources :agma_profiles, :only => [:show, :edit, :update]
  resources :sessions
  resources :users, :except => [:show]
  
  resources :locations, :employees do
  	get 'inactive', on: :collection
  	member do
  		get 'activate'
  		get 'inactivate'
  	end
  end
  
  resources :pieces do
  	resources :scenes, :characters, only: [:index, :new, :create]
  	get 'inactive', on: :collection
  	member do
  		get 'activate'
  		get 'inactivate'
  	end
  end
  resources :scenes, :characters, only: [:edit, :update, :destroy] do
  	collection { post :sort }
  end
  
  resources :events, :only => :index
  resources :rehearsals, :only => [:new, :create, :show, :edit, :update]
  resources :company_classes, :only => [:new, :create, :show, :edit, :update]
	
	match 'dashboard' => 'static_pages#dashboard'
	match 'features' => 'static_pages#features'   
	match 'pricing' => 'static_pages#pricing' 
	match 'contact' => 'static_pages#contact'
	
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
