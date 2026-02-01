puts "Seeding database..."

# Clear existing data
puts "Clearing existing data..."
OrderItem.destroy_all
Order.destroy_all
CartItem.destroy_all
Cart.destroy_all
Product.destroy_all
Brand.destroy_all
User.destroy_all
Role.destroy_all

# Create roles
puts "Creating roles..."
admin_role = Role.create!(name: 'admin')
mod_role = Role.create!(name: 'mod')

# Create users
puts "Creating users..."

# 1 Admin
admin = User.create!(
  name: 'Admin User',
  email: 'admin@acme.com',
  password: 'password123',
  password_confirmation: 'password123'
)
admin.add_role(:admin)
puts "  - Created admin: #{admin.email}"

# 5 Moderators
5.times do |i|
  mod = User.create!(
    name: FFaker::Name.name,
    email: "mod#{i + 1}@acme.com",
    password: 'password123',
    password_confirmation: 'password123'
  )
  mod.add_role(:mod)
  puts "  - Created mod: #{mod.email}"
end

# 14 Regular users
14.times do |i|
  user = User.create!(
    name: FFaker::Name.name,
    email: FFaker::Internet.email,
    password: 'password123',
    password_confirmation: 'password123'
  )
  puts "  - Created user: #{user.email}"
end

puts "Created #{User.count} users"

# Create brands
puts "Creating brands..."
brand_names = [
  'Apple', 'Samsung', 'Sony', 'Microsoft', 'Google', 'Amazon', 'Tesla', 'Nike',
  'Adidas', 'Puma', 'Reebok', 'Under Armour', 'New Balance', 'Converse', 'Vans',
  'Levi\'s', 'Gap', 'H&M', 'Zara', 'Uniqlo', 'Dell', 'HP', 'Lenovo', 'Asus',
  'Acer', 'LG', 'Panasonic', 'Philips', 'Bosch', 'Siemens', 'Dyson', 'Braun',
  'Canon', 'Nikon', 'Fujifilm', 'GoPro', 'DJI', 'Bose', 'JBL', 'Sonos',
  'Nintendo', 'PlayStation', 'Xbox', 'Razer', 'Logitech', 'Corsair', 'SteelSeries',
  'IKEA', 'Muji', 'Casio'
]

brands = brand_names.map do |name|
  brand = Brand.create!(name: name)
  puts "  - Created brand: #{name}"
  brand
end

puts "Created #{Brand.count} brands"

# Create products
puts "Creating products..."
product_categories = [
  { prefix: 'Laptop', price_range: 500..2500 },
  { prefix: 'Smartphone', price_range: 200..1500 },
  { prefix: 'Tablet', price_range: 150..1200 },
  { prefix: 'Headphones', price_range: 30..400 },
  { prefix: 'Speaker', price_range: 50..500 },
  { prefix: 'Watch', price_range: 50..800 },
  { prefix: 'Camera', price_range: 200..3000 },
  { prefix: 'TV', price_range: 300..3000 },
  { prefix: 'Monitor', price_range: 150..1500 },
  { prefix: 'Keyboard', price_range: 20..300 },
  { prefix: 'Mouse', price_range: 10..200 },
  { prefix: 'Controller', price_range: 30..150 },
  { prefix: 'Console', price_range: 300..600 },
  { prefix: 'Drone', price_range: 100..2000 },
  { prefix: 'Fitness Tracker', price_range: 50..300 },
  { prefix: 'E-Reader', price_range: 80..400 },
  { prefix: 'Charger', price_range: 15..100 },
  { prefix: 'Case', price_range: 10..80 },
  { prefix: 'Cable', price_range: 5..50 },
  { prefix: 'Stand', price_range: 20..200 }
]

adjectives = ['Pro', 'Max', 'Ultra', 'Lite', 'Plus', 'Elite', 'Air', 'Mini', 'Nano', 'Prime']
years = ['2024', '2025', '2026']

2500.times do |i|
  category = product_categories.sample
  brand = brands.sample
  adjective = adjectives.sample
  year = years.sample
  variant = rand(1..10)

  name = "#{brand.name} #{category[:prefix]} #{adjective} #{variant} #{year}"
  price = rand(category[:price_range])
  description = FFaker::Lorem.paragraph(3)

  Product.create!(
    name: name,
    description: description,
    price: price,
    brand: brand
  )

  print "\r  - Created #{i + 1}/2500 products" if (i + 1) % 100 == 0 || i == 2499
end

puts "\nCreated #{Product.count} products"

# Create some sample orders
puts "Creating sample orders..."
users = User.all.reject { |u| u.has_role?(:admin) || u.has_role?(:mod) }
products = Product.all

users.each do |user|
  num_orders = rand(0..5)
  num_orders.times do
    order = Order.create!(
      user: user,
      total: 0,
      status: ['pending', 'processing', 'shipped', 'delivered'].sample
    )

    num_items = rand(1..5)
    order_total = 0

    num_items.times do
      product = products.sample
      quantity = rand(1..3)
      unit_price = product.price

      OrderItem.create!(
        order: order,
        product: product,
        quantity: quantity,
        unit_price: unit_price
      )

      order_total += quantity * unit_price
    end

    order.update!(total: order_total)
  end
end

puts "Created #{Order.count} orders with #{OrderItem.count} order items"

puts "\nSeeding complete!"
puts "Summary:"
puts "  - Users: #{User.count} (1 admin, 5 mods, #{User.count - 6} regular)"
puts "  - Brands: #{Brand.count}"
puts "  - Products: #{Product.count}"
puts "  - Orders: #{Order.count}"
puts "\nLogin credentials:"
puts "  Admin: admin@acme.com / password123"
puts "  Mods: mod1@acme.com to mod5@acme.com / password123"
