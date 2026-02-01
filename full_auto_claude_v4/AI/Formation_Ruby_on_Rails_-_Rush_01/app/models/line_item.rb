# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :itemable, polymorphic: true

  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }

  def subtotal
    price.to_f * quantity.to_i
  end
end
