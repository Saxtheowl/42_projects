# frozen_string_literal: true

class GameController < ApplicationController
  before_action :init_globals

  def title
    $view = :title
    $selected = 0
  end

  def new_game
    $game = Game.new_game
    $player = { x: 0, y: 0 }
    $view = :worldmap
    redirect_to worldmap_path
  end

  def worldmap
    redirect_to title_path unless $game
    $view = :worldmap
  end

  def move
    redirect_to title_path unless $game

    direction = params[:direction]&.to_sym
    return redirect_to worldmap_path unless direction

    encounter = $game.move(direction)
    $player = { x: $game.player_x, y: $game.player_y }

    if encounter
      redirect_to battle_path
    else
      redirect_to worldmap_path
    end
  end

  def battle
    redirect_to worldmap_path unless $game&.current_moviemon
    $view = :battle
  end

  def fight
    redirect_to worldmap_path unless $game&.current_moviemon

    result = $game.fight
    $view = :battle

    case result
    when :captured
      redirect_to battle_result_path(result: 'captured')
    when :lost
      redirect_to battle_result_path(result: 'lost')
    else
      redirect_to battle_path
    end
  end

  def flee
    redirect_to worldmap_path unless $game
    $game.flee
    redirect_to battle_result_path(result: 'fled')
  end

  def battle_result
    redirect_to worldmap_path unless $game
    @result = params[:result]
    $view = :battle_result
  end

  def moviedex
    redirect_to worldmap_path unless $game
    $view = :moviedex

    captured = $game.captured_movies
    $selected ||= 0

    if captured.empty?
      @movie = nil
    else
      $selected = $selected % captured.length
      @movie = captured[$selected]
    end
  end

  def moviedex_navigate
    redirect_to worldmap_path unless $game

    direction = params[:direction]
    captured = $game.captured_movies

    unless captured.empty?
      case direction
      when 'left'
        $selected = ($selected - 1) % captured.length
      when 'right'
        $selected = ($selected + 1) % captured.length
      end
    end

    redirect_to moviedex_path
  end

  def save_slots
    $view = :save_slots
    @mode = params[:mode] || 'save'
    @from = params[:from] || 'worldmap'
    $selected ||= 0
    @saves = Game.load_all_saves
  end

  def save_navigate
    direction = params[:direction]

    case direction
    when 'up'
      $selected = ($selected - 1) % 3
    when 'down'
      $selected = ($selected + 1) % 3
    end

    redirect_to save_slots_path(mode: params[:mode], from: params[:from])
  end

  def save_game
    redirect_to worldmap_path unless $game

    slot = params[:slot] || $selected
    $game.save(slot)

    redirect_to worldmap_path
  end

  def load_game
    slot = params[:slot] || $selected
    loaded = Game.load(slot)

    if loaded
      $game = loaded
      $player = { x: $game.player_x, y: $game.player_y }
      redirect_to worldmap_path
    else
      redirect_to save_slots_path(mode: 'load', from: 'title')
    end
  end

  def power
    $view = nil
    $game = nil
    $player = nil
    $selected = 0
    redirect_to title_path
  end

  private

  def init_globals
    $view ||= :title
    $selected ||= 0
  end
end
