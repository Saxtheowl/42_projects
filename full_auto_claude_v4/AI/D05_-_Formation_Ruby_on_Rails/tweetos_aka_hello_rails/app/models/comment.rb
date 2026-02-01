# frozen_string_literal: true

# Comment model representing comments on cuicuis
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :cuicui

  validates :content, presence: true, uniqueness: true
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :cuicui_id, presence: true, numericality: { only_integer: true }
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
