require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      product = build(:product)
      expect(product).to be_valid
    end

    it 'is not valid without a name' do
      product = build(:product, name: nil)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without a price' do
      product = build(:product, price: nil)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("can't be blank")
    end

    it 'is not valid with a negative price' do
      product = build(:product, price: -1)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("must be greater than or equal to 0")
    end

    it 'is valid with a price of 0' do
      product = build(:product, price: 0)
      expect(product).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a brand' do
      assoc = described_class.reflect_on_association(:brand)
      expect(assoc.macro).to eq :belongs_to
    end
  end
end
