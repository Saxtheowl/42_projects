Rails.application.routes.draw do
  devise_for :users
  resources :chatrooms do
    resources :messages, only: [:create]
  end
  root 'chatrooms#index'
end
