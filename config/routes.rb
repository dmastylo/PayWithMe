PayWithMe::Application.routes.draw do

  root to: "pages#index"
  devise_for :users, controllers: { registrations: "my_devise/registrations", omniauth_callbacks: "my_devise/omniauth_callbacks", sessions: "my_devise/sessions", registrations: "my_devise/registrations", passwords: "my_devise/passwords" }
  match '/team', to: "pages#team"
  match '/privacy_policy', to: "pages#privacy_policy"
  match '/faq', to: "pages#faq"
  match '/jobs', to: "pages#jobs"

  resources :admin, only: :index do
    collection do
      get 'users'
      get 'events'
      get 'groups'
      get 'organizations'
      get 'payments'
    end
  end

  resources :contact_forms, only: [:new, :create]

  resources :events do
    resources :messages, only: :create
    resources :reminders, only: [:new, :create]
    resources :event_users, only: [:create] do
      member do
        put 'paid'
        put 'unpaid'
        put 'nudge'
      end
    end
    member do
      get 'admin'
      scope '/admin' do
        get 'guests'
      end
    end
  end
  resources :messages, only: :index

  resources :linked_accounts, only: [:destroy]

  resources :users, only: [:show] do
    collection do
      get 'search'
    end
  end

  resources :groups do
    collection do
      get 'search'
    end
  end

  resources :notifications do
    collection do
      post 'read'
    end
  end

  resources :event_users, only: [] do
    member do
      get 'pay'
    end
  end

  resources :payments, only: [] do
    member do
      get 'pin'
      post 'pay'
      post 'ipn'
    end
  end

  resources :organizations, only: [:new, :create]

  # Error Handling
  # ===========================================================================
  match "/404", :to => "errors#not_found"
  match "/500", :to => "errors#does_not_exist"

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
