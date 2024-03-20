Rails.application.routes.draw do
  extend CustomRoutes
  # NOTE: Uncomment this if mvi deployment is used
  # if Rails.env.production?
  #   mount MviDeployment::Engine => '/deployment'
  # end


  # Setup routes for devise
  devise_for :devise_model, skip: :registrations, controllers: { sessions: 'sessions' }
  namespace :admin do
    root to: 'dashboard#index'

    get '/cleanup_dropzone_upload', to: 'admin#cleanup_dropzone_upload', as: :cleanup_dropzone_upload
    get '/action_modal', to: 'application#action_modal', as: :action_modal
    patch '/destroy_uploads', to: 'admin#destroy_uploads', as: :destroy_uploads
    get 'dashboard/index'

    # FIXME: define your routes here
    resources :model_name, shallow: true do
    end

  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
