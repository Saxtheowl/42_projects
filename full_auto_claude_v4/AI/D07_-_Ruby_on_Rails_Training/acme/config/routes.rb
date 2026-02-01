Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users

  resources :products
  resources :brands
  resources :orders, only: [:index, :show]

  resource :cart, only: [:show] do
    post 'add/:id', to: 'carts#add', as: 'add_to'
    post 'increment/:id', to: 'carts#increment', as: 'increment'
    post 'decrement/:id', to: 'carts#decrement', as: 'decrement'
    delete 'remove/:id', to: 'carts#remove', as: 'remove_from'
    delete 'clear', to: 'carts#clear', as: 'clear'
    post 'checkout', to: 'carts#checkout', as: 'checkout'
  end

  root 'products#index'
end
