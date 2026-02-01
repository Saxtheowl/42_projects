# frozen_string_literal: true

Rails.application.routes.draw do
  root 'users#index'

  resources :users
  resources :cuicuis
  resources :comments
  resources :likes

  get 'up' => 'rails/health#show', as: :rails_health_check
end
