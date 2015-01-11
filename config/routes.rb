Rails.application.routes.draw do
  devise_for :users, skip: [:sessions]
  devise_scope :user do
    get 'login' => 'devise/sessions#new', as: :new_user_session
    post 'login' => 'devise/sessions#create', as: :user_session
    get 'logout' => 'devise/sessions#destroy', as: :destroy_user_session
  end
  get 'welcome/index'
  get 'welcome/login'
  
  #namespace :api do
  #namespace :v1 do
  #  get 'api_doc/index'
  #  end
  #end

  resources :users, only: [:index, :show]
  resources :businesses, only: [:index, :show]
  resources :welcome, only: [:index, :login, :show]
  resources :reviews, only: [:index, :show, :create]
  root 'welcome#index'
  namespace :api do
    resources :apps, only: [:create]
    namespace :v1 do
      get 'api_doc/index'
      resources :users, :businesses, :reviews
    end
  end
end
