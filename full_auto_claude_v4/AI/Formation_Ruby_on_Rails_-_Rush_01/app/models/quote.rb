# frozen_string_literal: true

class Quote < ApplicationRecord
  belongs_to :project
  has_many :line_items, as: :itemable, dependent: :destroy
  has_many :activity_logs, as: :trackable, dependent: :destroy

  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :all_blank

  validates :project, presence: true

  def calculate_total
    line_items.sum { |item| item.price.to_f * item.quantity.to_i }
  end

  def update_total!
    update(total: calculate_total)
  end

  delegate :client, to: :project
  delegate :user, to: :project
end
