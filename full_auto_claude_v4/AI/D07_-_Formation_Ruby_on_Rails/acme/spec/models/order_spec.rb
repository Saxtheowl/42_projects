require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      order = build(:order)
      expect(order).to be_valid
    end

    it 'is not valid without a status' do
      order = build(:order, status: nil)
      expect(order).not_to be_valid
      expect(order.errors[:status]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      assoc = described_class.reflect_on_association(:user)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'has many order_items' do
      assoc = described_class.reflect_on_association(:order_items)
      expect(assoc.macro).to eq :has_many
    end

    it 'has many products through order_items' do
      assoc = described_class.reflect_on_association(:products)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:through]).to eq :order_items
    end

    it 'destroys associated order_items when destroyed' do
      order = create(:order)
      create(:order_item, order: order)
      expect { order.destroy }.to change(OrderItem, :count).by(-1)
    end
  end

  describe '.create_from_cart' do
    let(:user) { create(:user) }
    let(:cart) { create(:cart) }
    let(:product1) { create(:product, price: 20.00) }
    let(:product2) { create(:product, price: 30.00) }

    context 'when cart is empty' do
      it 'returns nil' do
        expect(Order.create_from_cart(cart, user)).to be_nil
      end

      it 'does not create an order' do
        expect { Order.create_from_cart(cart, user) }.not_to change(Order, :count)
      end
    end

    context 'when cart has items' do
      before do
        create(:cart_item, cart: cart, product: product1, quantity: 2, unit_price: 20.00)
        create(:cart_item, cart: cart, product: product2, quantity: 1, unit_price: 30.00)
      end

      it 'creates an order' do
        expect { Order.create_from_cart(cart, user) }.to change(Order, :count).by(1)
      end

      it 'creates order items for each cart item' do
        expect { Order.create_from_cart(cart, user) }.to change(OrderItem, :count).by(2)
      end

      it 'sets the correct total' do
        order = Order.create_from_cart(cart, user)
        expect(order.total).to eq 70.00
      end

      it 'sets the status to pending' do
        order = Order.create_from_cart(cart, user)
        expect(order.status).to eq 'pending'
      end

      it 'clears the cart' do
        Order.create_from_cart(cart, user)
        expect(cart.cart_items.count).to eq 0
      end

      it 'associates the order with the user' do
        order = Order.create_from_cart(cart, user)
        expect(order.user).to eq user
      end
    end
  end
end
