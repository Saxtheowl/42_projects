require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is not valid without a name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
    end

    it 'is not valid without a password' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many orders' do
      assoc = described_class.reflect_on_association(:orders)
      expect(assoc.macro).to eq :has_many
    end

    it 'destroys associated orders when destroyed' do
      user = create(:user)
      create(:order, user: user)
      expect { user.destroy }.to change(Order, :count).by(-1)
    end
  end

  describe 'roles' do
    it 'can have admin role' do
      user = create(:user, :admin)
      expect(user.has_role?(:admin)).to be true
    end

    it 'can have mod role' do
      user = create(:user, :mod)
      expect(user.has_role?(:mod)).to be true
    end

    it 'can have multiple roles' do
      user = create(:user)
      user.add_role(:admin)
      user.add_role(:mod)
      expect(user.has_role?(:admin)).to be true
      expect(user.has_role?(:mod)).to be true
    end
  end
end
