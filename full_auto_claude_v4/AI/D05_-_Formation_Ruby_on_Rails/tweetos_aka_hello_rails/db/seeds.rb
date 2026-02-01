# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database.
# The data can then be loaded with the rake db:seed.

# Create users
users = User.create([
  { name: 'Alice', email: 'alice@example.com', since: 2010, admin: true, country: 'France' },
  { name: 'Bob', email: 'bob@example.com', since: 2015, admin: false, country: 'USA' },
  { name: 'Charlie', email: 'charlie@example.com', since: 2020, admin: false, country: 'UK' },
  { name: 'Diana', email: 'diana@example.com', since: 2005, admin: true, country: 'Germany' }
])

# Create cuicuis
cuicuis = Cuicui.create([
  { content: 'Hello world! This is my first cuicui!', user_id: users[0].id },
  { content: 'Rails is awesome!', user_id: users[0].id },
  { content: 'Learning Ruby on Rails today', user_id: users[1].id },
  { content: 'Coffee and code', user_id: users[2].id },
  { content: 'SQL is fundamental for web development', user_id: users[3].id }
])

# Create comments
Comment.create([
  { content: 'Great first post!', user_id: users[1].id, cuicui_id: cuicuis[0].id },
  { content: 'Welcome to the platform!', user_id: users[2].id, cuicui_id: cuicuis[0].id },
  { content: 'Totally agree!', user_id: users[3].id, cuicui_id: cuicuis[1].id },
  { content: 'Same here!', user_id: users[0].id, cuicui_id: cuicuis[2].id },
  { content: 'Nice!', user_id: users[1].id, cuicui_id: cuicuis[3].id }
])

# Create likes
Like.create([
  { user_id: users[1].id, cuicui_id: cuicuis[0].id },
  { user_id: users[2].id, cuicui_id: cuicuis[0].id },
  { user_id: users[3].id, cuicui_id: cuicuis[0].id },
  { user_id: users[0].id, cuicui_id: cuicuis[1].id },
  { user_id: users[2].id, cuicui_id: cuicuis[1].id },
  { user_id: users[0].id, cuicui_id: cuicuis[2].id },
  { user_id: users[3].id, cuicui_id: cuicuis[3].id }
])

puts "Seed completed: #{User.count} users, #{Cuicui.count} cuicuis, #{Comment.count} comments, #{Like.count} likes"
