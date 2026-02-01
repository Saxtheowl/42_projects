# frozen_string_literal: true

class Invoice < ApplicationRecord
  TYPES = %w[incoming outgoing].freeze

  belongs_to :project
  has_many :line_items, as: :itemable, dependent: :destroy
  has_many :activity_logs, as: :trackable, dependent: :destroy

  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :all_blank

  validates :project, presence: true
  validates :invoice_type, inclusion: { in: TYPES }

  scope :incoming, -> { where(invoice_type: 'incoming') }
  scope :outgoing, -> { where(invoice_type: 'outgoing') }

  def calculate_total
    line_items.sum { |item| item.price.to_f * item.quantity.to_i }
  end

  def update_total!
    update(total: calculate_total)
  end

  def incoming?
    invoice_type == 'incoming'
  end

  def outgoing?
    invoice_type == 'outgoing'
  end

  delegate :client, to: :project
  delegate :user, to: :project
end
