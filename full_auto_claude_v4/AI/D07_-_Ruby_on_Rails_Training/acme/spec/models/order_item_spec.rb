require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      order_item = build(:order_item)
      expect(order_item).to be_valid
    end

    it 'is not valid with a quantity of 0' do
      order_item = build(:order_item, quantity: 0)
      expect(order_item).not_to be_valid
      expect(order_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'is not valid with a negative quantity' do
      order_item = build(:order_item, quantity: -1)
      expect(order_item).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to an order' do
      assoc = described_class.reflect_on_association(:order)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'belongs to a product' do
      assoc = described_class.reflect_on_association(:product)
      expect(assoc.macro).to eq :belongs_to
    end
  end

  describe '#total_price' do
    it 'returns quantity multiplied by unit price' do
      order_item = build(:order_item, quantity: 4, unit_price: 12.50)
      expect(order_item.total_price).to eq 50.00
    end
  end
end
