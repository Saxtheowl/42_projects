# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

  # In-mails
  resources :in_mails, only: [:new, :create, :show] do
    collection do
      get :inbox
      get :outbox
      get :contacts
    end
    member do
      get :pdf
    end
  end

  # Clients
  resources :clients do
    collection do
      post :import
    end
  end

  # Projects with nested resources
  resources :projects do
    resources :quotes do
      member do
        get :pdf
      end
    end
    resources :orders do
      member do
        get :pdf
      end
    end
    resources :invoices do
      member do
        get :pdf
      end
    end
  end

  # Surveys
  resources :surveys do
    member do
      get :public_show
      post :respond
      get :thank_you
    end
  end

  # Admin namespace
  namespace :admin do
    root 'dashboard#index'
    resources :users
    resources :clients do
      collection do
        get :export
      end
    end
    resources :companies
    resources :projects
    resources :surveys do
      member do
        post :publish
        post :unpublish
        get :export_results
        get :export_emails
      end
      collection do
        post :import
      end
    end
    resources :in_mails, only: [:index, :show, :new, :create, :destroy] do
      collection do
        get :history
      end
    end
  end

  # Backoffice namespace (for managers)
  namespace :backoffice do
    root 'dashboard#index'
    resources :users, only: [:index, :show, :edit, :update]
    resources :clients, only: [:index, :show, :edit, :update, :destroy] do
      collection do
        get :export
      end
    end
    resources :activity_logs, only: [:index]
    get 'statistics', to: 'statistics#index'
    get 'statistics/by_client', to: 'statistics#by_client'
    get 'statistics/by_company', to: 'statistics#by_company'
    get 'statistics/global', to: 'statistics#global'
  end
end
