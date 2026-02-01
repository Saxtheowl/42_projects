# frozen_string_literal: true

# Clear existing data
Like.destroy_all
Comment.destroy_all
Cuicui.destroy_all
User.destroy_all

# Create users
users = [
  { name: 'Alice', email: 'alice@example.com', since: 2010, admin: true, country: 'France' },
  { name: 'Bob', email: 'bob@example.com', since: 2015, admin: false, country: 'USA' },
  { name: 'Charlie', email: 'charlie@example.com', since: 2020, admin: false, country: 'UK' },
  { name: 'Diana', email: 'diana@example.com', since: 2005, admin: true, country: 'Germany' }
]

created_users = users.map { |u| User.create!(u) }

# Create tweets (cuicuis)
cuicuis = [
  { content: 'Hello World!', user: created_users[0] },
  { content: 'Rails is awesome!', user: created_users[0] },
  { content: 'Learning SQL today', user: created_users[1] },
  { content: 'Active Record magic', user: created_users[2] },
  { content: 'Ruby is beautiful', user: created_users[3] }
]

created_cuicuis = cuicuis.map { |c| Cuicui.create!(c) }

# Create comments
comments = [
  { content: 'Great post!', user: created_users[1], cuicui: created_cuicuis[0] },
  { content: 'I agree!', user: created_users[2], cuicui: created_cuicuis[0] },
  { content: 'Thanks for sharing', user: created_users[3], cuicui: created_cuicuis[1] },
  { content: 'Very helpful', user: created_users[0], cuicui: created_cuicuis[2] },
  { content: 'Nice one', user: created_users[1], cuicui: created_cuicuis[3] }
]

comments.each { |c| Comment.create!(c) }

# Create likes
likes = [
  { user: created_users[1], cuicui: created_cuicuis[0] },
  { user: created_users[2], cuicui: created_cuicuis[0] },
  { user: created_users[3], cuicui: created_cuicuis[0] },
  { user: created_users[0], cuicui: created_cuicuis[2] },
  { user: created_users[2], cuicui: created_cuicuis[1] },
  { user: created_users[3], cuicui: created_cuicuis[4] }
]

likes.each { |l| Like.create!(l) }

puts 'Seed data created successfully!'
puts "Users: #{User.count}"
puts "Cuicuis: #{Cuicui.count}"
puts "Comments: #{Comment.count}"
puts "Likes: #{Like.count}"
