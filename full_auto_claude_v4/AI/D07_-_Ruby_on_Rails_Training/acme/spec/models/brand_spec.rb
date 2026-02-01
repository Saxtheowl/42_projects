require 'rails_helper'

RSpec.describe Brand, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      brand = build(:brand)
      expect(brand).to be_valid
    end

    it 'is not valid without a name' do
      brand = build(:brand, name: nil)
      expect(brand).not_to be_valid
      expect(brand.errors[:name]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many products' do
      assoc = described_class.reflect_on_association(:products)
      expect(assoc.macro).to eq :has_many
    end

    it 'destroys associated products when destroyed' do
      brand = create(:brand)
      create(:product, brand: brand)
      expect { brand.destroy }.to change(Product, :count).by(-1)
    end
  end
end
