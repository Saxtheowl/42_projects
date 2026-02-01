Rails.application.routes.draw do
  devise_for :users
  resources :messages, only: [:create]
  get 'rooms/show'
  root 'rooms#show'
end
