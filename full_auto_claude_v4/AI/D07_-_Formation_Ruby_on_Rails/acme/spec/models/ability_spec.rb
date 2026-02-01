require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe 'guest user' do
    let(:ability) { Ability.new(nil) }

    it 'can read products and brands' do
      expect(ability).to be_able_to(:read, Product.new)
      expect(ability).to be_able_to(:read, Brand.new)
    end

    it 'cannot read orders' do
      expect(ability).not_to be_able_to(:read, Order.new)
    end

    it 'cannot manage carts' do
      expect(ability).not_to be_able_to(:manage, Cart.new)
    end

    it 'cannot access rails_admin' do
      expect(ability).not_to be_able_to(:access, :rails_admin)
    end
  end

  describe 'regular user' do
    let(:user) { create(:user) }
    let(:ability) { Ability.new(user) }

    it 'can read products and brands' do
      expect(ability).to be_able_to(:read, Product.new)
      expect(ability).to be_able_to(:read, Brand.new)
    end

    it 'can manage carts' do
      expect(ability).to be_able_to(:manage, Cart.new)
    end

    it 'can manage cart items' do
      expect(ability).to be_able_to(:manage, CartItem.new)
    end

    it 'can read their own orders' do
      order = create(:order, user: user)
      expect(ability).to be_able_to(:read, order)
    end

    it 'cannot read other users orders' do
      other_user = create(:user)
      order = Order.new(user: other_user)
      expect(ability).not_to be_able_to(:read, order)
    end

    it 'cannot access rails_admin' do
      expect(ability).not_to be_able_to(:access, :rails_admin)
    end

    it 'cannot manage products' do
      expect(ability).not_to be_able_to(:manage, Product.new)
    end
  end

  describe 'mod user' do
    let(:user) { create(:user, :mod) }
    let(:ability) { Ability.new(user) }

    it 'can manage products' do
      expect(ability).to be_able_to(:manage, Product.new)
    end

    it 'can manage brands' do
      expect(ability).to be_able_to(:manage, Brand.new)
    end

    it 'can access rails_admin' do
      expect(ability).to be_able_to(:access, :rails_admin)
    end

    it 'can read dashboard' do
      expect(ability).to be_able_to(:read, :dashboard)
    end

    it 'cannot manage users' do
      expect(ability).not_to be_able_to(:manage, User.new)
    end
  end

  describe 'admin user' do
    let(:user) { create(:user, :admin) }
    let(:ability) { Ability.new(user) }

    it 'can manage all resources' do
      expect(ability).to be_able_to(:manage, :all)
    end

    it 'can access rails_admin' do
      expect(ability).to be_able_to(:access, :rails_admin)
    end

    it 'can read dashboard' do
      expect(ability).to be_able_to(:read, :dashboard)
    end
  end
end
