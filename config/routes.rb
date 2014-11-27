Rails.application.routes.draw do
  resources :users, only: [:index, :show]

  root 'users#index'
  namespace :api do
    resources :apps, only: [:create]
    namespace :v1 do
      resources :users, :businesses, :reviews
    end
  end
end
