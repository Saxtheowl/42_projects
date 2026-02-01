# frozen_string_literal: true

class Cuicui < ApplicationRecord
  # Exercise 03: Active Record Associations
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # Exercise 05: Validations
  validates :content, presence: true, uniqueness: true
  validates :user_id, presence: true, numericality: { only_integer: true }
  validate :user_must_exist

  # Exercise 09: Scope
  scope :top, lambda {
    left_joins(:likes)
      .group(:id)
      .order('COUNT(likes.id) DESC')
  }

  private

  def user_must_exist
    return if user_id.blank?
    return if User.exists?(user_id)

    errors.add(:user_id, 'must be a valid user')
  end
end
