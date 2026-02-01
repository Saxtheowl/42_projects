class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :status, presence: true

  def self.create_from_cart(cart, user)
    return nil if cart.empty?

    order = create!(user: user, total: cart.total_price, status: 'pending')

    cart.cart_items.each do |item|
      order.order_items.create!(
        product: item.product,
        quantity: item.quantity,
        unit_price: item.unit_price
      )
    end

    cart.clear!
    order
  end
end
