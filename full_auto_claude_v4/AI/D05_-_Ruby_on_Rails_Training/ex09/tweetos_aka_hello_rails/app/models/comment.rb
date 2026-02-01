# frozen_string_literal: true

class Comment < ApplicationRecord
  # Exercise 03: Active Record Associations
  belongs_to :user
  belongs_to :cuicui

  # Exercise 05: Validations
  validates :content, presence: true, uniqueness: true
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :cuicui_id, presence: true, numericality: { only_integer: true }
  validate :user_must_exist
  validate :cuicui_must_exist

  private

  def user_must_exist
    return if user_id.blank?
    return if User.exists?(user_id)

    errors.add(:user_id, 'must be a valid user')
  end

  def cuicui_must_exist
    return if cuicui_id.blank?
    return if Cuicui.exists?(cuicui_id)

    errors.add(:cuicui_id, 'must be a valid cuicui')
  end
end
