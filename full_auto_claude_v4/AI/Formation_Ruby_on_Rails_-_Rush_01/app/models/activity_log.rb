# frozen_string_literal: true

class ActivityLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :trackable, polymorphic: true, optional: true

  validates :action, presence: true

  scope :by_date, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_trackable, ->(trackable) { where(trackable: trackable) }

  def self.log(user, action, trackable = nil, details = nil)
    create(
      user: user,
      action: action,
      trackable: trackable,
      details: details
    )
  end

  def formatted_date
    created_at.strftime('%Y-%m-%d %H:%M')
  end
end
