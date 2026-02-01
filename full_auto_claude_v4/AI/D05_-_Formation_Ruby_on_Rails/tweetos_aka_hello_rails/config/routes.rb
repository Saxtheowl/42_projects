# frozen_string_literal: true

Rails.application.routes.draw do
  root 'users#index'

  resources :users
  resources :cuicuis
  resources :comments
  resources :likes

  get 'top' => 'cuicuis#top', as: :top_cuicuis
end
