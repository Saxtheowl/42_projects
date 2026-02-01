# Clean existing data
Vote.destroy_all
Post.destroy_all
User.destroy_all

# Create admin user
admin = User.create!(
  name: 'admin',
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  admin: true
)

# Create regular users with various privilege levels
user1 = User.create!(
  name: 'bob',
  email: 'bob@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)

user2 = User.create!(
  name: 'alice',
  email: 'alice@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)

user3 = User.create!(
  name: 'charlie',
  email: 'charlie@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)

user4 = User.create!(
  name: 'diana',
  email: 'diana@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)

# Create posts
post1 = Post.create!(
  user: user1,
  title: 'How to check if water is too hot',
  content: 'Test the water temperature with the inside of your wrist before bathing a baby.'
)

post2 = Post.create!(
  user: user2,
  title: 'Save money on groceries',
  content: 'Make a shopping list before going to the store and stick to it.'
)

post3 = Post.create!(
  user: user3,
  title: 'Better sleep habits',
  content: 'Stop using electronic devices at least 30 minutes before bedtime.'
)

post4 = Post.create!(
  user: admin,
  title: 'Productivity tip',
  content: 'Use the Pomodoro technique: work for 25 minutes, then take a 5 minute break.'
)

# Create votes to establish privileges
# Give user1 (bob) 10 upvotes so he can edit posts
[user2, user3, user4, admin].each do |voter|
  Vote.create!(user: voter, post: post1, value: 1)
end

# Additional votes to give bob more votes
Vote.create!(user: user2, post: post4, value: 1)
Vote.create!(user: user3, post: post4, value: 1)
Vote.create!(user: user4, post: post4, value: 1)

# Create votes on bob's posts via his own posts' association
# We need to give bob votes received, not votes given
# The total_votes_received counts votes on posts authored by bob
# Let's add more votes to bob's post
5.times do |i|
  voter = User.create!(
    name: "voter#{i}",
    email: "voter#{i}@example.com",
    password: 'password123',
    password_confirmation: 'password123'
  )
  Vote.create!(user: voter, post: post1, value: 1)
end

# Give alice (user2) 5 upvotes so she can upvote
[user1, user3, user4, admin].each do |voter|
  Vote.create!(user: voter, post: post2, value: 1)
end

# Give charlie (user3) 7 upvotes so he can downvote
[user1, user2, user4, admin].each do |voter|
  Vote.create!(user: voter, post: post3, value: 1)
end
3.times do |i|
  voter = User.create!(
    name: "voter_charlie#{i}",
    email: "voter_charlie#{i}@example.com",
    password: 'password123',
    password_confirmation: 'password123'
  )
  Vote.create!(user: voter, post: post3, value: 1)
end

# Create an edited post example
post2.update!(
  title: post2.title,
  content: 'Make a shopping list before going to the store, stick to it, and never shop hungry!',
  edited_by_id: user1.id,
  edited_at: Time.current
)

puts "Seed data created successfully!"
puts "Admin: admin@example.com / password123"
puts "Users: bob, alice, charlie, diana (all with password: password123)"
puts ""
puts "User privileges:"
puts "- bob: #{user1.reload.total_votes_received} votes (#{user1.privileges.join(', ')})"
puts "- alice: #{user2.reload.total_votes_received} votes (#{user2.privileges.join(', ')})"
puts "- charlie: #{user3.reload.total_votes_received} votes (#{user3.privileges.join(', ')})"
puts "- diana: #{user4.reload.total_votes_received} votes (#{user4.privileges.join(', ')})"
