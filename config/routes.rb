Rails.application.routes.draw do
  extend CustomRoutes
  # NOTE: Uncomment this if mvi deployment is used
  # if Rails.env.production?
  #   mount MviDeployment::Engine => '/deployment'
  # end


  # Setup routes for devise
  # config/routes.rb
  devise_for :users, skip: :registrations, controllers: { sessions: 'sessions' }

  namespace :admin do
    get 'due_rentals/index'
    get 'lookups/index'
    root to: 'dashboard#index'

    get '/cleanup_dropzone_upload', to: 'admin#cleanup_dropzone_upload', as: :cleanup_dropzone_upload
    get '/action_modal', to: 'application#action_modal', as: :action_modal
    patch '/destroy_uploads', to: 'admin#destroy_uploads', as: :destroy_uploads
    get 'dashboard/index'


    # FIXME: define your routes here
    # resources :model_name, shallow: true do
    # end
    get "lookups", to: "lookups#index"     # /admin/lookups
    resources :actors
    resources :genres
    

    resources :users do
      collection { get :export_pdf }
      resources :rentals, only: [:index, :new, :create, :edit, :update, :destroy] do
        member { patch :mark_returned }
        collection do
        end
      end
    end

    resources :movies do
      resources :copies, only: [:index, :new, :create, :edit, :update, :destroy]
      resources :castings, only: [:new, :create, :edit, :update, :destroy]
    end

   get "due_rentals", to: "due_rentals#index", as: :due_rentals

  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root "admin/dashboard#index"
end
