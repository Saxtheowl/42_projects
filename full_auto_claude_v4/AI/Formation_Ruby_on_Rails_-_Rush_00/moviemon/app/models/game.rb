# frozen_string_literal: true

require 'json'
require 'net/http'

class Game
  GRID_SIZE = 10
  MAX_ENERGY = 100
  BASE_HIT_POINT = 10
  ENCOUNTER_CHANCE = 0.3
  SAVE_FILE = Rails.root.join('saves', 'save.json').to_s

  attr_accessor :player_x, :player_y, :moviemons, :captured, :available,
                :player_energy, :player_hit_point, :current_moviemon

  def initialize
    @player_x = 0
    @player_y = 0
    @moviemons = {}
    @captured = []
    @available = []
    @player_energy = MAX_ENERGY
    @player_hit_point = BASE_HIT_POINT
    @current_moviemon = nil
  end

  def self.new_game
    game = new
    game.load_moviemons
    game
  end

  def load_moviemons
    movies = fetch_movies
    @moviemons = {}
    movies.each { |m| @moviemons[m[:id]] = m }
    @available = movies.map { |m| m[:id] }
    @captured = []
  end

  def fetch_movies
    monster_movies = [
      { id: 'godzilla', title: 'Godzilla', year: '2014', genre: 'Action, Sci-Fi',
        director: 'Gareth Edwards', rating: 6.4,
        plot: 'The world is beset by the appearance of monstrous creatures.',
        poster: 'https://m.media-amazon.com/images/M/MV5BN2E4MjIyMTk4OF5BMl5BanBnXkFtZTgwOTY2NTM3MTE@._V1_SX300.jpg' },
      { id: 'kong', title: 'Kong: Skull Island', year: '2017', genre: 'Action, Adventure',
        director: 'Jordan Vogt-Roberts', rating: 6.7,
        plot: 'A diverse team of scientists, soldiers and adventurers explore a mythical island.',
        poster: 'https://m.media-amazon.com/images/M/MV5BNDUxYzFkMDItMDkxYi00NTg4LWJkMTMtNGM3ZjUwNzE5YjYwXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_SX300.jpg' },
      { id: 'alien', title: 'Alien', year: '1979', genre: 'Horror, Sci-Fi',
        director: 'Ridley Scott', rating: 8.5,
        plot: 'After a space merchant vessel receives an unknown transmission, one of the crew is attacked.',
        poster: 'https://m.media-amazon.com/images/M/MV5BOGQzZTBjMjQtOTVmMS00NGE5LWEyYmMtOGQ1ZGZjNmRkYjFhXkEyXkFqcGdeQXVyMjUzOTY1NTc@._V1_SX300.jpg' },
      { id: 'jaws', title: 'Jaws', year: '1975', genre: 'Adventure, Thriller',
        director: 'Steven Spielberg', rating: 8.1,
        plot: 'When a killer shark unleashes chaos on a beach community, a police chief must hunt it.',
        poster: 'https://m.media-amazon.com/images/M/MV5BMmVmODY1MzEtYTMwZC00MzNhLWFkNDMtZjAwM2EwODUxZTA5XkEyXkFqcGdeQXVyNTAyODkwOQ@@._V1_SX300.jpg' },
      { id: 'predator', title: 'Predator', year: '1987', genre: 'Action, Sci-Fi',
        director: 'John McTiernan', rating: 7.8,
        plot: 'A team of commandos on a mission in a Central American jungle are hunted by an alien.',
        poster: 'https://m.media-amazon.com/images/M/MV5BY2QwYmFmZTEtNzY2Mi00ZWMyLWJkYTktNzUxZTMxMGJlY2RjXkEyXkFqcGdeQXVyNjUwNzk3NDc@._V1_SX300.jpg' },
      { id: 'thing', title: 'The Thing', year: '1982', genre: 'Horror, Mystery, Sci-Fi',
        director: 'John Carpenter', rating: 8.2,
        plot: 'A research team in Antarctica is hunted by a shape-shifting alien.',
        poster: 'https://m.media-amazon.com/images/M/MV5BNGViZWZmM2EtNGYzZi00ZDAyLTk3ODMtNzIyZTBjN2Y1NmM1XkEyXkFqcGdeQXVyNTAyODkwOQ@@._V1_SX300.jpg' },
      { id: 'cloverfield', title: 'Cloverfield', year: '2008', genre: 'Action, Horror, Sci-Fi',
        director: 'Matt Reeves', rating: 7.0,
        plot: 'A group of friends venture deep into the streets of New York during a monster attack.',
        poster: 'https://m.media-amazon.com/images/M/MV5BZDNhNDJlNDktZDEzMi00ZTViLWJkZDktN2FiZjFkZDY2ODI3XkEyXkFqcGdeQXVyNTIzOTk5ODM@._V1_SX300.jpg' },
      { id: 'pacific', title: 'Pacific Rim', year: '2013', genre: 'Action, Sci-Fi',
        director: 'Guillermo del Toro', rating: 6.9,
        plot: 'Humans pilot giant robots to fight monstrous creatures from another dimension.',
        poster: 'https://m.media-amazon.com/images/M/MV5BMTY3MTI5NjQ4Nl5BMl5BanBnXkFtZTcwOTU1OTU0OQ@@._V1_SX300.jpg' },
      { id: 'jurassic', title: 'Jurassic Park', year: '1993', genre: 'Action, Adventure, Sci-Fi',
        director: 'Steven Spielberg', rating: 8.2,
        plot: 'A pragmatic paleontologist visits an almost complete theme park with cloned dinosaurs.',
        poster: 'https://m.media-amazon.com/images/M/MV5BMjM2MDgxMDg0Nl5BMl5BanBnXkFtZTgwNTM2OTM5NDE@._V1_SX300.jpg' },
      { id: 'tremors', title: 'Tremors', year: '1990', genre: 'Comedy, Horror',
        director: 'Ron Underwood', rating: 7.1,
        plot: 'Natives of a small isolated town defend themselves against strange underground creatures.',
        poster: 'https://m.media-amazon.com/images/M/MV5BMTkzNTIwMzctYWNjNy00MzU0LTk2MWItMzdiMTRhYjQ2NTc5XkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg' }
    ]
    monster_movies
  end

  def move(direction)
    case direction
    when :up
      @player_y = [@player_y - 1, 0].max
    when :down
      @player_y = [@player_y + 1, GRID_SIZE - 1].min
    when :left
      @player_x = [@player_x - 1, 0].max
    when :right
      @player_x = [@player_x + 1, GRID_SIZE - 1].min
    end
    check_encounter
  end

  def check_encounter
    return nil if @available.empty?
    return nil if rand > ENCOUNTER_CHANCE

    idx = rand(@available.length)
    moviemon_id = @available[idx]
    @current_moviemon = @moviemons[moviemon_id].dup
    @current_moviemon[:energy] = (@current_moviemon[:rating] * 10).to_i
    @current_moviemon[:max_energy] = @current_moviemon[:energy]
    moviemon_id
  end

  def fight
    return nil unless @current_moviemon

    moviemon_dmg = @player_hit_point
    player_dmg = @current_moviemon[:rating].to_i

    @current_moviemon[:energy] -= moviemon_dmg
    @player_energy -= player_dmg

    if @current_moviemon[:energy] <= 0
      capture_moviemon
      :captured
    elsif @player_energy <= 0
      lose_moviemon
      :lost
    else
      :continue
    end
  end

  def capture_moviemon
    return unless @current_moviemon

    id = @current_moviemon[:id]
    @captured << id unless @captured.include?(id)
    @available.delete(id)
    @player_energy = MAX_ENERGY
    @player_hit_point += 2
    @current_moviemon = nil
  end

  def lose_moviemon
    return unless @current_moviemon

    id = @current_moviemon[:id]
    @available.delete(id)
    @player_energy = MAX_ENERGY
    @current_moviemon = nil
  end

  def flee
    @player_energy = MAX_ENERGY
    @current_moviemon = nil
  end

  def get_movie(id)
    @moviemons[id]
  end

  def captured_movies
    @captured.map { |id| @moviemons[id] }
  end

  def save(slot)
    FileUtils.mkdir_p(File.dirname(SAVE_FILE))

    saves = load_all_saves
    saves[slot.to_s] = {
      player_x: @player_x,
      player_y: @player_y,
      captured: @captured,
      available: @available,
      player_energy: @player_energy,
      player_hit_point: @player_hit_point,
      moviemons: @moviemons,
      saved_at: Time.now.to_s
    }

    File.write(SAVE_FILE, JSON.pretty_generate(saves))
  end

  def self.load(slot)
    saves = load_all_saves
    data = saves[slot.to_s]
    return nil unless data

    game = new
    game.player_x = data['player_x']
    game.player_y = data['player_y']
    game.captured = data['captured'] || []
    game.available = data['available'] || []
    game.player_energy = data['player_energy'] || MAX_ENERGY
    game.player_hit_point = data['player_hit_point'] || BASE_HIT_POINT

    game.moviemons = {}
    (data['moviemons'] || {}).each do |id, m|
      game.moviemons[id] = m.transform_keys(&:to_sym)
    end

    game
  end

  def self.load_all_saves
    return {} unless File.exist?(SAVE_FILE)
    JSON.parse(File.read(SAVE_FILE))
  rescue JSON::ParserError
    {}
  end

  def load_all_saves
    self.class.load_all_saves
  end

  def to_json(*_args)
    {
      player_x: @player_x,
      player_y: @player_y,
      captured: @captured,
      available: @available,
      player_energy: @player_energy,
      player_hit_point: @player_hit_point,
      current_moviemon: @current_moviemon
    }.to_json
  end
end
