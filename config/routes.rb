Rails.application.routes.draw do
  extend CustomRoutes
  # NOTE: Uncomment this if mvi deployment is used
  # if Rails.env.production?
  #   mount MviDeployment::Engine => '/deployment'
  # end
  get :status, to: 'public#status'

  devise_for :users, skip: :registrations, controllers: { sessions: 'sessions' }
  namespace :admin do
    root to: 'dashboard#index'

    get '/cleanup_dropzone_upload', to: 'admin#cleanup_dropzone_upload', as: :cleanup_dropzone_upload

    get '/action_modal', to: 'application#action_modal', as: :action_modal

    patch '/destroy_uploads', to: 'admin#destroy_uploads', as: :destroy_uploads

    get 'dashboard/index'
    resources :movie_actors, shallow: true
    resources :actors, shallow: true  do
      resources :movie_actors, shallow: true
    end

    resources :communication_records, shallow: true
    resources :genres, shallow: true
    resources :movie_copies, shallow: true
    resources :movies, shallow: true  do
      resources :movie_actors, shallow: true
      resources :movie_copies, shallow: true
    end

    resources :movie_genres, shallow: true
    resources :movie_notifications, shallow: true
    resources :orders, shallow: true
    resources :order_movie_copies, shallow: true
    resources :users, shallow: true do
      member do
        get :reset_password
      end

      resources :movie_notifications, shallow: true
      resources :orders, shallow: true
    end

    resources :user_ratings, shallow: true
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
