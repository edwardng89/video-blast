Rails.application.routes.draw do
  extend CustomRoutes

  devise_for :users,
    controllers: {
      sessions: 'sessions',
      registrations: 'registrations'
    }

  # Public catalog (read-only)
  namespace :public do
    get 'notifications/index'
    get 'notifications/create'
    get 'notifications/destroy'
    resources :movies, only: [:index, :show]

    resource :cart, only: [:show], controller: "cart" do
      post   :add    # add_public_cart_path
      patch  :update # update_public_cart_path
      delete :clear  # clear_public_cart_path
    end

    resources :rentals, only: [:index, :show, :create]
    resources :notifications, only: [:index, :create, :destroy]
  end

  get "/videos", to: "public/movies#index", as: :videos

  namespace :admin do
    root to: 'dashboard#index' # <-- public root for admin's login

    get '/cleanup_dropzone_upload', to: 'admin#cleanup_dropzone_upload', as: :cleanup_dropzone_upload
    get '/action_modal',            to: 'application#action_modal',      as: :action_modal
    patch '/destroy_uploads',       to: 'admin#destroy_uploads',         as: :destroy_uploads

    get 'dashboard/index'
    get "lookups", to: "lookups#index"
    get "due_rentals", to: "due_rentals#index", as: :due_rentals

    resources :actors
    resources :genres

    resources :users do
      collection { get :export_pdf }
      resources :rentals, only: [:index, :new, :create, :edit, :update, :destroy] do
        member { patch :mark_returned }
      end
    end

    resources :movies do
      resources :copies,   only: [:index, :new, :create, :edit, :update, :destroy]
      resources :castings, only: [:new, :create, :edit, :update, :destroy]
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  root "home#index"  # <-- public root for user's login
end
