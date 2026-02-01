# frozen_string_literal: true

class FtQueryController < ApplicationController
  def index
    @time_stamps = fetch_time_stamps
    @all = $all || ['Not so fast, young padawan']
    @runner_1 = $runner_1
    @runner_2 = $runner_2
    @runner_3 = $runner_3
    @runner_4 = $runner_4
  end

  # Exercise 00: Create database file
  def create_db
    $db = SQLite3::Database.new('ft_sql')
    redirect_to root_path
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to root_path
  end

  # Exercise 00: Create tables
  def create_table
    return redirect_to root_path unless $db

    begin
      $db.execute <<-SQL
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
        );
      SQL

      $db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS race (
          r_id INTEGER PRIMARY KEY AUTOINCREMENT,
          start VARCHAR(50)
        );
      SQL
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to root_path
  end

  # Exercise 00: Drop tables
  def drop_table
    return redirect_to root_path unless $db

    begin
      $db.execute('DROP TABLE IF EXISTS clock_watch;')
      $db.execute('DROP TABLE IF EXISTS race;')
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to root_path
  end

  # Exercise 02: Start race - subscribe runners
  def start_race
    return redirect_to root_path unless $db

    begin
      now = Time.now
      race_start = now.to_s

      $db.execute('INSERT INTO race (start) VALUES (?)', [race_start])
      race_id = $db.last_insert_row_id

      names = [
        query_params[:name_1].presence || 'anonymous',
        query_params[:name_2].presence || 'anonymous',
        query_params[:name_3].presence || 'anonymous',
        query_params[:name_4].presence || 'anonymous'
      ]

      $runner_1 = names[0]
      $runner_2 = names[1]
      $runner_3 = names[2]
      $runner_4 = names[3]

      names.each do |name|
        $db.execute(
          'INSERT INTO clock_watch (day, month, year, hour, min, sec, race, name, lap) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [now.day, now.month, now.year, now.hour, now.min, now.sec, race_id, name, 0]
        )
      end
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to root_path
  end

  # Exercise 04: Insert timestamp for lap
  def insert_time_stamp
    return redirect_to root_path unless $db

    begin
      name = query_params[:name]
      return redirect_to root_path if name.blank?

      race_id = $db.get_first_value('SELECT MAX(r_id) FROM race')
      return redirect_to root_path unless race_id

      current_lap = $db.get_first_value(
        'SELECT MAX(lap) FROM clock_watch WHERE name = ? AND race = ?',
        [name, race_id]
      ) || 0

      now = Time.now
      $db.execute(
        'INSERT INTO clock_watch (day, month, year, hour, min, sec, race, name, lap) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [now.day, now.month, now.year, now.hour, now.min, now.sec, race_id, name, current_lap + 1]
      )
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to root_path
  end

  # Exercise 06: Delete all records
  def delete_all
    return redirect_to root_path unless $db

    begin
      $db.execute('DELETE FROM clock_watch;')
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to root_path
  end

  # Exercise 06: Delete last record
  def delete_last
    return redirect_to root_path unless $db

    begin
      last_id = $db.get_first_value('SELECT MAX(ts_id) FROM clock_watch')
      $db.execute('DELETE FROM clock_watch WHERE ts_id = ?', [last_id]) if last_id
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to root_path
  end

  # Exercise 08: Select all by name
  def all_by_name
    return redirect_to root_path unless $db

    begin
      $all = $db.execute('SELECT * FROM clock_watch ORDER BY name')
    rescue StandardError => e
      flash[:error] = e.message
      $all = ['Database is empty or an other error occurred']
    end
    redirect_to root_path
  end

  # Exercise 08: Select all by race
  def all_by_race
    return redirect_to root_path unless $db

    begin
      $all = $db.execute('SELECT * FROM clock_watch ORDER BY race')
    rescue StandardError => e
      flash[:error] = e.message
      $all = ['Database is empty or an other error occurred']
    end
    redirect_to root_path
  end

  # Exercise 10: Update name
  def update_name
    return redirect_to root_path unless $db

    begin
      old_name = query_params[:old_name]
      new_name = query_params[:new_name]

      return redirect_to root_path if old_name.blank? || new_name.blank?
      return redirect_to root_path if old_name == 'anonymous'

      race_id = $db.get_first_value('SELECT MAX(r_id) FROM race')
      return redirect_to root_path unless race_id

      $db.execute(
        'UPDATE clock_watch SET name = ? WHERE name = ? AND race = ? AND name != ?',
        [new_name, old_name, race_id, 'anonymous']
      )
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to root_path
  end

  private

  def query_params
    params.permit(:name_1, :name_2, :name_3, :name_4, :name, :old_name, :new_name)
  end

  def fetch_time_stamps
    return ['Database is empty or an other error occurred'] unless $db

    begin
      result = $db.execute('SELECT * FROM clock_watch')
      result.empty? ? ['Database is empty or an other error occurred'] : result
    rescue StandardError
      ['Database is empty or an other error occurred']
    end
  end
end
