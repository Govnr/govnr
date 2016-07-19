Rails.application.routes.draw do

  wiki_root '/wiki'

  devise_for :admin_users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  devise_for :users, :path => '', :path_names => { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register' },
    :controllers => { registrations: 'registrations' }
  devise_scope :user do
    get 'login' => 'devise/sessions#new', :as => :get_new_user_session
    post 'login' => 'devise/sessions#create', :as => :post_new_user_session
    get 'register' => 'devise/registrations#new', :as =>  :get_new_registration
    post 'register' => 'devise/registrations#new', :as =>  :post_new_registration
    delete 'logout', :to => 'users/sessions#destroy', :as => :destroy_user_session_path
  end

  
  authenticated :user do
    root :to => 'pages#dashboard', as: :authenticated_root
  end
  
  # get 'login' => 'devise/sessions#new'
  # get 'signup' => 'users#new'
  # get 'profile' => 'sessions#profile'
  # get 'settings' => 'sessions#setting'
  # get 'logout' => 'sessions#logout'

  resources :users do
    member do
      post :signin
    end
    collection do
      post :signout
    end
  end

  # resources :comments, only: [:index, :create]
  # get '/comments/new/(:parent_id)', to: 'comments#new', as: :new_comment
  post 'comments/report/', :to => 'comments#report', :as => :new_comment_report
  concern :commentable do
    resources :comments
  end

  resources :petitions do
     resources :comments
  end
  # get "petitions/support/", :to => 'petitions#support', :as => :petition_support
  post 'petitions/support', :to => 'petitions#support', :as => :petition_support_post
  get 'data/petitions', :to => 'data#petitions', :as => 'data_petitions'
  resources :messages, only: [:new, :create]
  resources :conversations, only: [:index, :show, :destroy]

  # resources :conversations, :controller => "user_conversations" do
  #   resources :messages
  #   member do
  #     post :mark_as_read
  #     post :mark_as_unread
  #   end
  # end

 get '/dashboard' => 'pages#dashboard'
 get '/' => 'pages#index'

# match "signup", :to => "users#new"
# match "login", :to => "sessions#login"
# match "logout", :to => "sessions#logout"
# match "home", :to => "sessions#home"
# match "profile", :to => "sessions#profile"
# match "setting", :to => "sessions#setting"

 # match ':controller(/:action(/:id))', :via => get()

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  
  root 'pages#index'

  get 'tags/:tag', to: 'petitions#index', as: :tag

  get ':controller(/:action(/:id))(.:format)'

    # get 'tags/:tag', to: 'petitions#index', as: :tag

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
