require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'associations' do
    it 'has and belongs to many users' do
      assoc = described_class.reflect_on_association(:users)
      expect(assoc.macro).to eq :has_and_belongs_to_many
    end
  end
end
