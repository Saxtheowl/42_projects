# frozen_string_literal: true

Rails.application.routes.draw do
  root 'ft_query#index'

  get 'create_db', to: 'ft_query#create_db'
  get 'create_table', to: 'ft_query#create_table'
  get 'drop_table', to: 'ft_query#drop_table'
  post 'start_race', to: 'ft_query#start_race'
  post 'insert_time_stamp', to: 'ft_query#insert_time_stamp'
  get 'delete_all', to: 'ft_query#delete_all'
  get 'delete_last', to: 'ft_query#delete_last'
  get 'all_by_name', to: 'ft_query#all_by_name'
  get 'all_by_race', to: 'ft_query#all_by_race'
  post 'update_name', to: 'ft_query#update_name'

  get 'up' => 'rails/health#show', as: :rails_health_check
end
