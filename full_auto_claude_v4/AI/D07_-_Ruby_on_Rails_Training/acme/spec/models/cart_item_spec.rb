require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      cart_item = build(:cart_item)
      expect(cart_item).to be_valid
    end

    it 'is not valid with a quantity of 0' do
      cart_item = build(:cart_item, quantity: 0)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'is not valid with a negative quantity' do
      cart_item = build(:cart_item, quantity: -1)
      expect(cart_item).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a cart' do
      assoc = described_class.reflect_on_association(:cart)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'belongs to a product' do
      assoc = described_class.reflect_on_association(:product)
      expect(assoc.macro).to eq :belongs_to
    end
  end

  describe '#total_price' do
    it 'returns quantity multiplied by unit price' do
      cart_item = build(:cart_item, quantity: 3, unit_price: 15.00)
      expect(cart_item.total_price).to eq 45.00
    end
  end

  describe '#increment_quantity' do
    it 'increases quantity by 1' do
      cart_item = create(:cart_item, quantity: 2)
      expect { cart_item.increment_quantity }.to change(cart_item, :quantity).by(1)
    end
  end

  describe '#decrement_quantity' do
    context 'when quantity is greater than 1' do
      it 'decreases quantity by 1' do
        cart_item = create(:cart_item, quantity: 3)
        expect { cart_item.decrement_quantity }.to change(cart_item, :quantity).by(-1)
      end

      it 'does not destroy the cart item' do
        cart_item = create(:cart_item, quantity: 3)
        expect { cart_item.decrement_quantity }.not_to change(CartItem, :count)
      end
    end

    context 'when quantity is 1' do
      it 'destroys the cart item' do
        cart_item = create(:cart_item, quantity: 1)
        expect { cart_item.decrement_quantity }.to change(CartItem, :count).by(-1)
      end
    end
  end
end
