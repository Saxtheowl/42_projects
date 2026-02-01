# frozen_string_literal: true

class InMail < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User', optional: true

  validates :subject, :body, presence: true
  validates :sender, presence: true

  scope :unread, -> { where(read: false) }
  scope :by_date, -> { order(created_at: :desc) }

  def mark_as_read!
    update(read: true) unless read?
  end

  def self.send_to_group(sender, group, subject, body)
    User.where(operator_group: group).each do |user|
      create(sender: sender, recipient: user, subject: subject, body: body, read: false)
    end
  end

  def self.send_to_all(sender, subject, body)
    User.where.not(id: sender.id).each do |user|
      create(sender: sender, recipient: user, subject: subject, body: body, read: false)
    end
  end
end
