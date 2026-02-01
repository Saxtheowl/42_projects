#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'json'
require 'fileutils'
require 'pathname'

# Minimal Rails mock for testing
module Rails
  def self.root
    Pathname.new(File.expand_path('..', __dir__))
  end
end

require_relative '../app/models/game'

class GameTest < Minitest::Test
  def setup
    @game = Game.new
    # Clean up any test saves
    FileUtils.rm_f(Game::SAVE_FILE)
  end

  def teardown
    FileUtils.rm_f(Game::SAVE_FILE)
  end

  def test_initialize
    assert_equal 0, @game.player_x
    assert_equal 0, @game.player_y
    assert_empty @game.moviemons
    assert_empty @game.captured
    assert_empty @game.available
    assert_equal Game::MAX_ENERGY, @game.player_energy
    assert_equal Game::BASE_HIT_POINT, @game.player_hit_point
    assert_nil @game.current_moviemon
  end

  def test_new_game_loads_moviemons
    game = Game.new_game
    refute_empty game.moviemons
    refute_empty game.available
    assert_empty game.captured
  end

  def test_move_up
    @game.player_y = 5
    @game.move(:up)
    assert_equal 4, @game.player_y
  end

  def test_move_down
    @game.player_y = 5
    @game.move(:down)
    assert_equal 6, @game.player_y
  end

  def test_move_left
    @game.player_x = 5
    @game.move(:left)
    assert_equal 4, @game.player_x
  end

  def test_move_right
    @game.player_x = 5
    @game.move(:right)
    assert_equal 6, @game.player_x
  end

  def test_cannot_move_outside_grid_top
    @game.player_y = 0
    @game.move(:up)
    assert_equal 0, @game.player_y
  end

  def test_cannot_move_outside_grid_bottom
    @game.player_y = Game::GRID_SIZE - 1
    @game.move(:down)
    assert_equal Game::GRID_SIZE - 1, @game.player_y
  end

  def test_cannot_move_outside_grid_left
    @game.player_x = 0
    @game.move(:left)
    assert_equal 0, @game.player_x
  end

  def test_cannot_move_outside_grid_right
    @game.player_x = Game::GRID_SIZE - 1
    @game.move(:right)
    assert_equal Game::GRID_SIZE - 1, @game.player_x
  end

  def test_fetch_movies_returns_array
    movies = @game.fetch_movies
    assert_kind_of Array, movies
    refute_empty movies
  end

  def test_each_movie_has_required_fields
    movies = @game.fetch_movies
    movies.each do |movie|
      assert movie[:id], "Movie should have id"
      assert movie[:title], "Movie should have title"
      assert movie[:director], "Movie should have director"
      assert movie[:rating], "Movie should have rating"
      assert movie[:poster], "Movie should have poster"
      assert movie[:plot], "Movie should have plot"
    end
  end

  def test_get_movie_returns_movie_data
    @game.load_moviemons
    movie = @game.get_movie('godzilla')
    assert_equal 'Godzilla', movie[:title]
  end

  def test_get_movie_returns_nil_for_unknown
    @game.load_moviemons
    movie = @game.get_movie('nonexistent')
    assert_nil movie
  end

  def test_capture_moviemon
    @game.load_moviemons
    @game.current_moviemon = { id: 'godzilla', energy: 0 }

    @game.capture_moviemon

    assert_includes @game.captured, 'godzilla'
    refute_includes @game.available, 'godzilla'
    assert_nil @game.current_moviemon
    assert_equal Game::MAX_ENERGY, @game.player_energy
  end

  def test_capture_increases_hit_point
    @game.load_moviemons
    initial_hit = @game.player_hit_point
    @game.current_moviemon = { id: 'godzilla', energy: 0 }

    @game.capture_moviemon

    assert_equal initial_hit + 2, @game.player_hit_point
  end

  def test_lose_moviemon
    @game.load_moviemons
    @game.current_moviemon = { id: 'godzilla', energy: 10 }

    @game.lose_moviemon

    refute_includes @game.captured, 'godzilla'
    refute_includes @game.available, 'godzilla'
    assert_nil @game.current_moviemon
    assert_equal Game::MAX_ENERGY, @game.player_energy
  end

  def test_flee_restores_energy
    @game.load_moviemons
    @game.player_energy = 50
    @game.current_moviemon = { id: 'godzilla', energy: 10 }

    @game.flee

    assert_equal Game::MAX_ENERGY, @game.player_energy
    assert_nil @game.current_moviemon
    # MovieMon should still be available
    assert_includes @game.available, 'godzilla'
  end

  def test_fight_damages_both
    @game.load_moviemons
    @game.current_moviemon = {
      id: 'godzilla',
      energy: 100,
      max_energy: 100,
      rating: 6.4
    }

    initial_player_energy = @game.player_energy
    initial_moviemon_energy = @game.current_moviemon[:energy]

    result = @game.fight

    assert_equal :continue, result
    assert @game.player_energy < initial_player_energy
    assert @game.current_moviemon[:energy] < initial_moviemon_energy
  end

  def test_fight_capture_when_moviemon_dies
    @game.load_moviemons
    @game.player_hit_point = 100
    @game.current_moviemon = {
      id: 'godzilla',
      energy: 10,
      max_energy: 64,
      rating: 6.4
    }

    result = @game.fight

    assert_equal :captured, result
    assert_includes @game.captured, 'godzilla'
  end

  def test_fight_lost_when_player_dies
    @game.load_moviemons
    @game.player_energy = 1
    @game.player_hit_point = 1
    @game.current_moviemon = {
      id: 'godzilla',
      energy: 100,
      max_energy: 100,
      rating: 10
    }

    result = @game.fight

    assert_equal :lost, result
  end

  def test_save_and_load
    @game.load_moviemons
    @game.player_x = 5
    @game.player_y = 7
    @game.captured = ['godzilla']
    @game.player_energy = 80

    @game.save(0)

    loaded = Game.load(0)

    assert_equal 5, loaded.player_x
    assert_equal 7, loaded.player_y
    assert_equal ['godzilla'], loaded.captured
    assert_equal 80, loaded.player_energy
  end

  def test_save_creates_valid_json
    @game.load_moviemons
    @game.save(0)

    content = File.read(Game::SAVE_FILE)
    parsed = JSON.parse(content)

    assert_kind_of Hash, parsed
    assert parsed.key?('0')
  end

  def test_load_nonexistent_slot_returns_nil
    loaded = Game.load(99)
    assert_nil loaded
  end

  def test_captured_movies_returns_movie_data
    @game.load_moviemons
    @game.captured = ['godzilla', 'kong']

    captured = @game.captured_movies

    assert_equal 2, captured.length
    assert_equal 'Godzilla', captured[0][:title]
    assert_equal 'Kong: Skull Island', captured[1][:title]
  end

  def test_grid_size_is_at_least_10
    assert Game::GRID_SIZE >= 10
  end

  def test_to_json
    @game.player_x = 3
    @game.player_y = 4

    json = @game.to_json
    parsed = JSON.parse(json)

    assert_equal 3, parsed['player_x']
    assert_equal 4, parsed['player_y']
  end
end

class GameNoLoopTest < Minitest::Test
  def test_no_forbidden_loops_in_game_model
    file_content = File.read(File.expand_path('../app/models/game.rb', __dir__))

    forbidden_keywords = %w[while for redo break retry loop until]

    # Check for standalone forbidden keywords (not in comments or strings)
    forbidden_keywords.each do |keyword|
      # Match keyword as standalone word, not part of another word
      pattern = /(?<![a-zA-Z_])#{keyword}(?![a-zA-Z_])/

      lines = file_content.lines
      lines.each_with_index do |line, idx|
        # Skip comments
        next if line.strip.start_with?('#')

        # Check if the keyword appears outside of strings
        stripped = line.gsub(/"[^"]*"|'[^']*'/, '')  # Remove string literals
        stripped = stripped.split('#').first || ''  # Remove inline comments

        refute_match pattern, stripped,
                     "Forbidden keyword '#{keyword}' found at line #{idx + 1}"
      end
    end
  end
end

puts "Running Game Model Tests..."
