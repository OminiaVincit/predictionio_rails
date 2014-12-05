Rails.application.routes.draw do
  #namespace :api do
  #namespace :v1 do
  #  get 'api_doc/index'
  #  end
  #end

  resources :users, only: [:index, :show]

  root 'users#index'
  namespace :api do
    resources :apps, only: [:create]
    namespace :v1 do
      get 'api_doc/index'
      resources :users, :businesses, :reviews
    end
  end
end
