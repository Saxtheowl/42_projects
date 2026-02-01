Rails.application.routes.draw do
  root 'posts#index'

  # Session routes
  get 'login', to: 'sessions#new', as: :login
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: :logout

  # User routes
  resources :users, only: [:new, :create, :show, :edit, :update]
  get 'signup', to: 'users#new', as: :signup

  # Post routes
  resources :posts do
    member do
      post 'upvote'
      post 'downvote'
    end
  end

  # Admin namespace
  namespace :admin do
    resources :users, only: [:index, :edit, :update, :destroy]
    resources :posts, only: [:index, :edit, :update, :destroy]
    resources :votes, only: [:index, :destroy]
  end
end
