# frozen_string_literal: true

require 'test_helper'

class FtQueryControllerTest < ActionController::TestCase
  # Ex00 tests
  test 'db_file_creation' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    assert File.exist?('ft_sql'), 'Database file ft_sql should be created'
    assert_not_nil $db, 'Global $db should be set'
  end

  test 'db_table_creation' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    get :create_table
    tables = $db.execute("SELECT name FROM sqlite_master WHERE type='table'")
    table_names = tables.flatten
    assert table_names.include?('clock_watch'), 'clock_watch table should exist'
    assert table_names.include?('race'), 'race table should exist'

    # Check clock_watch columns
    clock_watch_info = $db.execute('PRAGMA table_info(clock_watch)')
    column_names = clock_watch_info.map { |col| col[1] }
    assert_equal %w[ts_id day month year hour min sec race name lap], column_names

    # Check race columns
    race_info = $db.execute('PRAGMA table_info(race)')
    race_column_names = race_info.map { |col| col[1] }
    assert_equal %w[r_id start], race_column_names
  end

  test 'db_drop_table' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    get :create_table
    get :drop_table
    tables = $db.execute("SELECT name FROM sqlite_master WHERE type='table'")
    table_names = tables.flatten.reject { |t| t == 'sqlite_sequence' }
    assert_empty table_names, 'All tables should be dropped'
  end

  # Ex02 tests
  test 'start_race' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    get :create_table
    post :start_race, name_1: 'foo', name_2: 'bar', name_3: '', name_4: ''

    # Check race was created
    races = $db.execute('SELECT * FROM race')
    assert_equal 1, races.length, 'One race should be created'

    # Check timestamps
    timestamps = $db.execute('SELECT * FROM clock_watch')
    assert_equal 4, timestamps.length, 'Four timestamps should be created'

    names = timestamps.map { |ts| ts[8] }
    assert names.include?('foo'), 'foo should be in the timestamps'
    assert names.include?('bar'), 'bar should be in the timestamps'
    assert_equal 2, names.count('anonymous'), 'Two anonymous should be in the timestamps'

    # All laps should be 0
    timestamps.each do |ts|
      assert_equal 0, ts[9], 'All laps should be 0 at start'
    end
  end

  # Ex04 tests
  test 'insert_time_stamp' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    get :create_table
    post :start_race, name_1: 'runner1', name_2: 'runner2', name_3: '', name_4: ''

    # Insert a timestamp for runner1
    post :insert_time_stamp, name: 'runner1'

    timestamps = $db.execute("SELECT * FROM clock_watch WHERE name = 'runner1' ORDER BY lap")
    assert_equal 2, timestamps.length, 'Runner1 should have 2 timestamps'
    assert_equal 0, timestamps[0][9], 'First lap should be 0'
    assert_equal 1, timestamps[1][9], 'Second lap should be 1'
  end

  # Ex06 tests
  test 'delete_last' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    get :create_table
    post :start_race, name_1: 'a', name_2: 'b', name_3: 'c', name_4: 'd'

    initial_count = $db.execute('SELECT COUNT(*) FROM clock_watch')[0][0]
    get :delete_last
    final_count = $db.execute('SELECT COUNT(*) FROM clock_watch')[0][0]

    assert_equal initial_count - 1, final_count, 'One timestamp should be deleted'
  end

  test 'delete_all' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    get :create_table
    post :start_race, name_1: 'a', name_2: 'b', name_3: 'c', name_4: 'd'

    get :delete_all
    count = $db.execute('SELECT COUNT(*) FROM clock_watch')[0][0]

    assert_equal 0, count, 'All timestamps should be deleted'
  end

  # Ex08 tests
  test 'all_by_name' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    get :create_table
    post :start_race, name_1: 'zebra', name_2: 'alpha', name_3: 'beta', name_4: 'gamma'

    get :all_by_name
    names = $all.map { |ts| ts[8] }

    sorted_names = names.sort
    assert_equal sorted_names, names, 'Records should be sorted by name'
  end

  test 'all_by_race' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    get :create_table
    post :start_race, name_1: 'a', name_2: 'b', name_3: 'c', name_4: 'd'
    post :start_race, name_1: 'e', name_2: 'f', name_3: 'g', name_4: 'h'

    get :all_by_race
    race_ids = $all.map { |ts| ts[7] }

    sorted_race_ids = race_ids.sort
    assert_equal sorted_race_ids, race_ids, 'Records should be sorted by race'
  end

  # Ex10 tests
  test 'update_name' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    get :create_table
    post :start_race, name_1: 'old_name', name_2: 'other', name_3: '', name_4: ''
    post :insert_time_stamp, name: 'old_name'

    post :update_name, old_name: 'old_name', new_name: 'new_name'

    timestamps = $db.execute("SELECT * FROM clock_watch WHERE name = 'old_name'")
    assert_empty timestamps, 'No timestamps with old name should exist'

    new_timestamps = $db.execute("SELECT * FROM clock_watch WHERE name = 'new_name'")
    assert_equal 2, new_timestamps.length, 'Two timestamps with new name should exist'
  end

  test 'update_name_anonymous_unchanged' do
    File.delete('ft_sql') if File.exist?('ft_sql')
    get :create_db
    get :create_table
    post :start_race, name_1: '', name_2: '', name_3: '', name_4: ''

    post :update_name, old_name: 'anonymous', new_name: 'new_name'

    anon_timestamps = $db.execute("SELECT * FROM clock_watch WHERE name = 'anonymous'")
    assert_equal 4, anon_timestamps.length, 'Anonymous users should not be updated'
  end
end
