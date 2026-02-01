# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :client
  belongs_to :user

  has_many :quotes, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :activity_logs, as: :trackable, dependent: :destroy

  validates :name, presence: true

  def total_revenue
    invoices.where(invoice_type: 'outgoing').sum(:total)
  end

  def total_expenses
    invoices.where(invoice_type: 'incoming').sum(:total)
  end

  def profit
    total_revenue - total_expenses
  end

  def total_orders
    orders.sum(:total)
  end
end
