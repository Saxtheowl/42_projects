# frozen_string_literal: true

require 'test_helper'

class FtQueryControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Clean up any existing database
    File.delete('ft_sql') if File.exist?('ft_sql')
    $db = nil
    $runner_1 = nil
    $runner_2 = nil
    $runner_3 = nil
    $runner_4 = nil
    $all = nil
  end

  def teardown
    File.delete('ft_sql') if File.exist?('ft_sql')
    $db = nil
  end

  # Exercise 00: Database file creation
  test 'db_file_creation' do
    get create_db_path
    assert_redirected_to root_path
    assert File.exist?('ft_sql'), 'ft_sql file should exist'
    assert_not_nil $db, '$db should be set'
    assert_instance_of SQLite3::Database, $db
  end

  # Exercise 00: Table creation
  test 'db_table_creation' do
    get create_db_path
    get create_table_path
    assert_redirected_to root_path

    tables = $db.execute("SELECT name FROM sqlite_master WHERE type='table'")
    table_names = tables.map(&:first)
    assert_includes table_names, 'clock_watch'
    assert_includes table_names, 'race'

    # Verify clock_watch columns
    clock_watch_info = $db.execute('PRAGMA table_info(clock_watch)')
    column_names = clock_watch_info.map { |col| col[1] }
    %w[ts_id day month year hour min sec race name lap].each do |col|
      assert_includes column_names, col, "clock_watch should have column #{col}"
    end

    # Verify race columns
    race_info = $db.execute('PRAGMA table_info(race)')
    column_names = race_info.map { |col| col[1] }
    %w[r_id start].each do |col|
      assert_includes column_names, col, "race should have column #{col}"
    end
  end

  # Exercise 00: Drop table
  test 'db_drop_table' do
    get create_db_path
    get create_table_path
    get drop_table_path
    assert_redirected_to root_path

    tables = $db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name IN ('clock_watch', 'race')")
    assert_empty tables, 'Tables should be dropped'
  end

  # Exercise 02: Start race
  test 'start_race' do
    get create_db_path
    get create_table_path

    post start_race_path, params: { name_1: 'Alice', name_2: 'Bob', name_3: '', name_4: '' }
    assert_redirected_to root_path

    # Check runners
    assert_equal 'Alice', $runner_1
    assert_equal 'Bob', $runner_2
    assert_equal 'anonymous', $runner_3
    assert_equal 'anonymous', $runner_4

    # Check clock_watch entries
    entries = $db.execute('SELECT * FROM clock_watch')
    assert_equal 4, entries.length

    names = entries.map { |e| e[8] }
    assert_includes names, 'Alice'
    assert_includes names, 'Bob'
    assert_equal 2, names.count('anonymous')

    # Check race entry
    races = $db.execute('SELECT * FROM race')
    assert_equal 1, races.length
  end

  # Exercise 04: Insert timestamp
  test 'insert_time_stamp' do
    get create_db_path
    get create_table_path
    post start_race_path, params: { name_1: 'Alice', name_2: 'Bob', name_3: '', name_4: '' }

    initial_count = $db.get_first_value('SELECT COUNT(*) FROM clock_watch WHERE name = ?', ['Alice'])

    post insert_time_stamp_path, params: { name: 'Alice' }
    assert_redirected_to root_path

    new_count = $db.get_first_value('SELECT COUNT(*) FROM clock_watch WHERE name = ?', ['Alice'])
    assert_equal initial_count + 1, new_count

    # Check lap incremented
    max_lap = $db.get_first_value('SELECT MAX(lap) FROM clock_watch WHERE name = ?', ['Alice'])
    assert_equal 1, max_lap
  end

  # Exercise 06: Delete all
  test 'delete_all' do
    get create_db_path
    get create_table_path
    post start_race_path, params: { name_1: 'Alice', name_2: 'Bob', name_3: '', name_4: '' }

    get delete_all_path
    assert_redirected_to root_path

    count = $db.get_first_value('SELECT COUNT(*) FROM clock_watch')
    assert_equal 0, count
  end

  # Exercise 06: Delete last
  test 'delete_last' do
    get create_db_path
    get create_table_path
    post start_race_path, params: { name_1: 'Alice', name_2: 'Bob', name_3: '', name_4: '' }

    initial_count = $db.get_first_value('SELECT COUNT(*) FROM clock_watch')
    last_id = $db.get_first_value('SELECT MAX(ts_id) FROM clock_watch')

    get delete_last_path
    assert_redirected_to root_path

    new_count = $db.get_first_value('SELECT COUNT(*) FROM clock_watch')
    assert_equal initial_count - 1, new_count

    deleted_check = $db.get_first_value('SELECT COUNT(*) FROM clock_watch WHERE ts_id = ?', [last_id])
    assert_equal 0, deleted_check
  end

  # Exercise 08: All by name
  test 'all_by_name' do
    get create_db_path
    get create_table_path
    post start_race_path, params: { name_1: 'Zoe', name_2: 'Alice', name_3: 'Bob', name_4: '' }

    get all_by_name_path
    assert_redirected_to root_path

    assert_not_nil $all
    assert $all.is_a?(Array)
    names = $all.map { |row| row[8] }
    assert_equal names.sort, names, 'Results should be sorted by name'
  end

  # Exercise 08: All by race
  test 'all_by_race' do
    get create_db_path
    get create_table_path
    post start_race_path, params: { name_1: 'Alice', name_2: 'Bob', name_3: '', name_4: '' }
    post start_race_path, params: { name_1: 'Charlie', name_2: 'Diana', name_3: '', name_4: '' }

    get all_by_race_path
    assert_redirected_to root_path

    assert_not_nil $all
    assert $all.is_a?(Array)
    races = $all.map { |row| row[7] }
    assert_equal races.sort, races, 'Results should be sorted by race'
  end

  # Exercise 10: Update name
  test 'update_name' do
    get create_db_path
    get create_table_path
    post start_race_path, params: { name_1: 'Alice', name_2: 'Bob', name_3: '', name_4: '' }

    post update_name_path, params: { old_name: 'Alice', new_name: 'Alicia' }
    assert_redirected_to root_path

    alice_count = $db.get_first_value('SELECT COUNT(*) FROM clock_watch WHERE name = ?', ['Alice'])
    alicia_count = $db.get_first_value('SELECT COUNT(*) FROM clock_watch WHERE name = ?', ['Alicia'])

    assert_equal 0, alice_count, 'Alice should be renamed'
    assert_equal 1, alicia_count, 'Alicia should exist'
  end

  # Exercise 10: Anonymous should not be updated
  test 'update_name_anonymous_protected' do
    get create_db_path
    get create_table_path
    post start_race_path, params: { name_1: '', name_2: '', name_3: '', name_4: '' }

    initial_anonymous = $db.get_first_value('SELECT COUNT(*) FROM clock_watch WHERE name = ?', ['anonymous'])

    post update_name_path, params: { old_name: 'anonymous', new_name: 'NotAnonymous' }
    assert_redirected_to root_path

    final_anonymous = $db.get_first_value('SELECT COUNT(*) FROM clock_watch WHERE name = ?', ['anonymous'])
    assert_equal initial_anonymous, final_anonymous, 'Anonymous entries should not be renamed'
  end
end
