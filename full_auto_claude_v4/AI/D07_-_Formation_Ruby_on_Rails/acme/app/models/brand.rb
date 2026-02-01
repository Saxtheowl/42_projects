class Brand < ApplicationRecord
  mount_uploader :avatar, AvatarUploader

  has_many :products, dependent: :destroy

  validates :name, presence: true
end
