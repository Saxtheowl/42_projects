# frozen_string_literal: true

# Like model representing likes on cuicuis
class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :cuicui

  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :cuicui_id, presence: true, numericality: { only_integer: true }
  validates :user_id, uniqueness: { scope: :cuicui_id }
  validate :user_exists
  validate :cuicui_exists

  private

  def user_exists
    return if user_id.nil?

    errors.add(:user_id, 'must exist') unless User.exists?(user_id)
  end

  def cuicui_exists
    return if cuicui_id.nil?

    errors.add(:cuicui_id, 'must exist') unless Cuicui.exists?(cuicui_id)
  end
end
