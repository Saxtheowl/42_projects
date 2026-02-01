# ACME E-Commerce Platform

A full-featured e-commerce web application built with Ruby on Rails.

## Features

- **User Authentication** (Devise)
  - User registration and login
  - Password recovery
  - Remember me functionality

- **Product Management**
  - Browse products with pagination
  - Product details with images
  - Filter by brand

- **Brand Management**
  - Product categorization by brand
  - Brand logos with image upload

- **Shopping Cart**
  - Session-based cart (no login required to browse)
  - Add/remove products
  - Increment/decrement quantities
  - Cart total calculation

- **Order System**
  - Checkout from cart
  - Order history
  - Order status tracking

- **Admin Panel** (rails_admin)
  - Full CRUD for all models
  - Dashboard with statistics
  - User management

- **Role-Based Access Control** (CanCanCan + Rolify)
  - Admin: Full access to all features
  - Mod: Manage products and brands
  - User: Browse, cart, and orders

## Technology Stack

- **Framework**: Ruby on Rails 5.2.8.1
- **Ruby Version**: 2.7.8
- **Database**: SQLite (development/test), PostgreSQL (production)
- **Authentication**: Devise
- **Authorization**: CanCanCan + Rolify
- **Admin Panel**: rails_admin
- **Image Upload**: CarrierWave + Cloudinary
- **Pagination**: Kaminari
- **Testing**: RSpec, FactoryBot, Capybara
- **Fake Data**: FFaker

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd acme
```

2. Install dependencies:
```bash
bundle install
```

3. Setup database:
```bash
rails db:create db:migrate db:seed
```

4. Start the server:
```bash
rails server
```

5. Visit `http://localhost:3000`

## Test Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@acme.com | password123 |
| Mod | mod1@acme.com | password123 |
| Mod | mod2@acme.com | password123 |
| Mod | mod3@acme.com | password123 |
| Mod | mod4@acme.com | password123 |
| Mod | mod5@acme.com | password123 |

Regular users are created with random emails during seeding.

## Database Schema

### Users
- name (string)
- email (string)
- encrypted_password (string)
- Devise fields for authentication

### Brands
- name (string)
- avatar (string) - Cloudinary image

### Products
- name (string)
- description (text)
- price (decimal)
- pict (string) - Cloudinary image
- brand_id (foreign key)

### Carts
- session_id (string)

### CartItems
- cart_id (foreign key)
- product_id (foreign key)
- quantity (integer)
- unit_price (decimal)

### Orders
- user_id (foreign key)
- total (decimal)
- status (string)

### OrderItems
- order_id (foreign key)
- product_id (foreign key)
- quantity (integer)
- unit_price (decimal)

### Roles (Rolify)
- name (string)
- resource_type (string)
- resource_id (integer)

## Routes

| Path | Description |
|------|-------------|
| `/` | Product listing (home) |
| `/products` | All products |
| `/products/:id` | Product details |
| `/brands` | All brands |
| `/brands/:id` | Brand details |
| `/cart` | Shopping cart |
| `/orders` | Order history |
| `/admin` | Admin panel |
| `/users/sign_in` | Login |
| `/users/sign_up` | Registration |

## Testing

Run the test suite:
```bash
bundle exec rspec
```

Run specific tests:
```bash
bundle exec rspec spec/models
bundle exec rspec spec/requests
```

## Seed Data

The seed file creates:
- 20 users (1 admin, 5 mods, 14 regular)
- 50 brands
- 2500 products
- Sample orders

Run seeding:
```bash
rails db:seed
```

## Environment Variables (Production)

For Cloudinary image uploads in production:
```bash
CLOUDINARY_URL=cloudinary://API_KEY:API_SECRET@CLOUD_NAME
```

## Deployment (Heroku)

1. Create Heroku app:
```bash
heroku create acme-store
```

2. Add PostgreSQL:
```bash
heroku addons:create heroku-postgresql:hobby-dev
```

3. Deploy:
```bash
git push heroku main
```

4. Setup database:
```bash
heroku run rails db:migrate db:seed
```

## License

MIT License
