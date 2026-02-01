require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'associations' do
    it 'has many cart_items' do
      assoc = described_class.reflect_on_association(:cart_items)
      expect(assoc.macro).to eq :has_many
    end

    it 'has many products through cart_items' do
      assoc = described_class.reflect_on_association(:products)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:through]).to eq :cart_items
    end

    it 'destroys associated cart_items when destroyed' do
      cart = create(:cart)
      create(:cart_item, cart: cart)
      expect { cart.destroy }.to change(CartItem, :count).by(-1)
    end
  end

  describe '#add_product' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 25.00) }

    context 'when product is not in cart' do
      it 'creates a new cart item' do
        expect { cart.add_product(product) }.to change(cart.cart_items, :count).by(1)
      end

      it 'sets the quantity to 1' do
        cart.add_product(product)
        expect(cart.cart_items.last.quantity).to eq 1
      end

      it 'sets the unit price to product price' do
        cart.add_product(product)
        expect(cart.cart_items.last.unit_price).to eq product.price
      end
    end

    context 'when product is already in cart' do
      before { cart.add_product(product) }

      it 'does not create a new cart item' do
        expect { cart.add_product(product) }.not_to change(cart.cart_items, :count)
      end

      it 'increments the quantity' do
        expect { cart.add_product(product) }.to change { cart.cart_items.find_by(product: product).quantity }.by(1)
      end
    end
  end

  describe '#total_price' do
    let(:cart) { create(:cart) }

    it 'returns 0 for an empty cart' do
      expect(cart.total_price).to eq 0
    end

    it 'returns the sum of all cart item total prices' do
      create(:cart_item, cart: cart, quantity: 2, unit_price: 10.00)
      create(:cart_item, cart: cart, quantity: 3, unit_price: 5.00)
      expect(cart.total_price).to eq 35.00
    end
  end

  describe '#total_items' do
    let(:cart) { create(:cart) }

    it 'returns 0 for an empty cart' do
      expect(cart.total_items).to eq 0
    end

    it 'returns the total quantity of all items' do
      create(:cart_item, cart: cart, quantity: 2)
      create(:cart_item, cart: cart, quantity: 3)
      expect(cart.total_items).to eq 5
    end
  end

  describe '#empty?' do
    let(:cart) { create(:cart) }

    it 'returns true for an empty cart' do
      expect(cart.empty?).to be true
    end

    it 'returns false when cart has items' do
      create(:cart_item, cart: cart)
      expect(cart.empty?).to be false
    end
  end

  describe '#clear!' do
    let(:cart) { create(:cart) }

    it 'removes all cart items' do
      create(:cart_item, cart: cart)
      create(:cart_item, cart: cart)
      expect { cart.clear! }.to change(cart.cart_items, :count).to(0)
    end
  end
end
