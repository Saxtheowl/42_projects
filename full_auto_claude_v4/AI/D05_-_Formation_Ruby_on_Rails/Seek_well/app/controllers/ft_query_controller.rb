# frozen_string_literal: true

# FtQueryController handles SQL database operations for race timing
class FtQueryController < ApplicationController
  def index
    init_db_connection
    @time_stamps = $time_stamps
    @all = $all
  rescue StandardError
    $time_stamps = ['Database is empty or an other error occured']
    $all = ['Not so fast, young padawan']
    @time_stamps = $time_stamps
    @all = $all
  end

  def create_db
    $db = SQLite3::Database.new('ft_sql')
    redirect_to root_path
  rescue StandardError
    redirect_to root_path
  end

  def create_table
    init_db_connection
    create_clock_watch_table
    create_race_table
    redirect_to root_path
  rescue StandardError
    redirect_to root_path
  end

  def drop_table
    init_db_connection
    $db.execute('DROP TABLE IF EXISTS clock_watch')
    $db.execute('DROP TABLE IF EXISTS race')
    redirect_to root_path
  rescue StandardError
    redirect_to root_path
  end

  def start_race
    init_db_connection
    time = Time.now
    names = extract_names
    race_id = create_race(time)
    create_timestamps_for_race(names, time, race_id)
    set_runner_vars(names)
    redirect_to root_path
  rescue StandardError
    redirect_to root_path
  end

  def insert_time_stamp
    init_db_connection
    name = query_params[:name] || 'anonymous'
    time = Time.now
    race_id = get_last_race_id
    lap = get_next_lap(name, race_id)
    insert_timestamp(time, name, lap, race_id)
    redirect_to root_path
  rescue StandardError
    redirect_to root_path
  end

  def delete_last
    init_db_connection
    $db.execute('DELETE FROM clock_watch WHERE ts_id = (SELECT MAX(ts_id) FROM clock_watch)')
    redirect_to root_path
  rescue StandardError
    redirect_to root_path
  end

  def delete_all
    init_db_connection
    $db.execute('DELETE FROM clock_watch')
    redirect_to root_path
  rescue StandardError
    redirect_to root_path
  end

  def all_by_name
    init_db_connection
    $all = $db.execute('SELECT * FROM clock_watch ORDER BY name')
    redirect_to root_path
  rescue StandardError
    $all = ['Database is empty or an other error occured']
    redirect_to root_path
  end

  def all_by_race
    init_db_connection
    $all = $db.execute('SELECT * FROM clock_watch ORDER BY race')
    redirect_to root_path
  rescue StandardError
    $all = ['Database is empty or an other error occured']
    redirect_to root_path
  end

  def update_name
    init_db_connection
    old_name = query_params[:old_name]
    new_name = query_params[:new_name]
    race_id = get_last_race_id
    return redirect_to root_path if old_name == 'anonymous'

    $db.execute(
      'UPDATE clock_watch SET name = ? WHERE name = ? AND race = ?',
      [new_name, old_name, race_id]
    )
    redirect_to root_path
  rescue StandardError
    redirect_to root_path
  end

  private

  def query_params
    params.permit(:name_1, :name_2, :name_3, :name_4, :name, :old_name, :new_name)
  end

  def init_db_connection
    return if $db && File.exist?('ft_sql')

    $db = SQLite3::Database.new('ft_sql') if File.exist?('ft_sql')
    load_time_stamps
    $all ||= ['Not so fast, young padawan']
  end

  def load_time_stamps
    return unless $db

    result = $db.execute('SELECT * FROM clock_watch')
    $time_stamps = result.empty? ? ['Database is empty or an other error occured'] : result
  rescue StandardError
    $time_stamps = ['Database is empty or an other error occured']
  end

  def create_clock_watch_table
    $db.execute(<<-SQL)
      CREATE TABLE IF NOT EXISTS clock_watch (
        ts_id INTEGER PRIMARY KEY AUTOINCREMENT,
        day INTEGER,
        month INTEGER,
        year INTEGER,
        hour INTEGER,
        min INTEGER,
        sec INTEGER,
        race INTEGER,
        name VARCHAR(50),
        lap INTEGER
      )
    SQL
  end

  def create_race_table
    $db.execute(<<-SQL)
      CREATE TABLE IF NOT EXISTS race (
        r_id INTEGER PRIMARY KEY AUTOINCREMENT,
        start VARCHAR(50)
      )
    SQL
  end

  def extract_names
    [
      query_params[:name_1].presence || 'anonymous',
      query_params[:name_2].presence || 'anonymous',
      query_params[:name_3].presence || 'anonymous',
      query_params[:name_4].presence || 'anonymous'
    ]
  end

  def create_race(time)
    $db.execute('INSERT INTO race (start) VALUES (?)', [time.to_s])
    $db.last_insert_row_id
  end

  def create_timestamps_for_race(names, time, race_id)
    names.each do |name|
      insert_timestamp(time, name, 0, race_id)
    end
  end

  def insert_timestamp(time, name, lap, race_id)
    $db.execute(
      'INSERT INTO clock_watch (day, month, year, hour, min, sec, race, name, lap) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [time.day, time.month, time.year, time.hour, time.min, time.sec, race_id, name, lap]
    )
  end

  def set_runner_vars(names)
    $runner_1 = names[0]
    $runner_2 = names[1]
    $runner_3 = names[2]
    $runner_4 = names[3]
  end

  def get_last_race_id
    result = $db.execute('SELECT MAX(r_id) FROM race')
    result[0][0] || 0
  end

  def get_next_lap(name, race_id)
    result = $db.execute(
      'SELECT MAX(lap) FROM clock_watch WHERE name = ? AND race = ?',
      [name, race_id]
    )
    (result[0][0] || -1) + 1
  end
end
