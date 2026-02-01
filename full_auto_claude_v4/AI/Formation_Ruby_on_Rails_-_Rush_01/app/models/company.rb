# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :clients, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  def self.ordered_by_name
    order(:name)
  end
end
