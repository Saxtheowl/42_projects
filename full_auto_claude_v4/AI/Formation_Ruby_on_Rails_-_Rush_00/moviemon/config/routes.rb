# frozen_string_literal: true

Rails.application.routes.draw do
  root 'game#title'

  get 'title', to: 'game#title'
  get 'new_game', to: 'game#new_game'
  get 'worldmap', to: 'game#worldmap'
  get 'move/:direction', to: 'game#move', as: :move
  get 'battle', to: 'game#battle'
  get 'fight', to: 'game#fight'
  get 'flee', to: 'game#flee'
  get 'battle_result', to: 'game#battle_result'
  get 'moviedex', to: 'game#moviedex'
  get 'moviedex_navigate/:direction', to: 'game#moviedex_navigate', as: :moviedex_navigate
  get 'save_slots', to: 'game#save_slots'
  get 'save_navigate/:direction', to: 'game#save_navigate', as: :save_navigate
  get 'save_game', to: 'game#save_game'
  get 'load_game', to: 'game#load_game'
  get 'power', to: 'game#power'
end
