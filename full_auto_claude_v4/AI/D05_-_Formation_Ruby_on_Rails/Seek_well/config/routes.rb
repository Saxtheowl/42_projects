# frozen_string_literal: true

Rails.application.routes.draw do
  root 'ft_query#index'

  get 'create_db' => 'ft_query#create_db', as: :create_db
  get 'create_table' => 'ft_query#create_table', as: :create_table
  get 'drop_table' => 'ft_query#drop_table', as: :drop_table
  post 'start_race' => 'ft_query#start_race', as: :start_race
  post 'insert_time_stamp' => 'ft_query#insert_time_stamp', as: :insert_time_stamp
  get 'delete_last' => 'ft_query#delete_last', as: :delete_last
  get 'delete_all' => 'ft_query#delete_all', as: :delete_all
  get 'all_by_name' => 'ft_query#all_by_name', as: :all_by_name
  get 'all_by_race' => 'ft_query#all_by_race', as: :all_by_race
  post 'update_name' => 'ft_query#update_name', as: :update_name
end
