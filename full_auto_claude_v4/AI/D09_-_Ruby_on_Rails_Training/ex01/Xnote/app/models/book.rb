class Book < ApplicationRecord
  validates :name, uniqueness: true
end
