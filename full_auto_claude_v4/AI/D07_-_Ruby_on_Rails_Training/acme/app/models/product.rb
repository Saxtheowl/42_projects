class Product < ApplicationRecord
  mount_uploader :pict, PictUploader

  belongs_to :brand

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
