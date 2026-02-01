class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def add_product(product)
    current_item = cart_items.find_by(product_id: product.id)

    if current_item
      current_item.increment(:quantity)
      current_item.save
    else
      cart_items.create(product: product, quantity: 1, unit_price: product.price)
    end
  end

  def total_price
    cart_items.sum { |item| item.total_price }
  end

  def total_items
    cart_items.sum(:quantity)
  end

  def empty?
    cart_items.empty?
  end

  def clear!
    cart_items.destroy_all
  end
end
