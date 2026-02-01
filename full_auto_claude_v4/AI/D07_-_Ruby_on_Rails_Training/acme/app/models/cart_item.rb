class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  def total_price
    quantity * unit_price
  end

  def increment_quantity
    self.quantity += 1
    save
  end

  def decrement_quantity
    if quantity > 1
      self.quantity -= 1
      save
    else
      destroy
    end
  end
end
