# frozen_string_literal: true

# Cuicui model representing tweets in the tweetos application
class Cuicui < ActiveRecord::Base
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :content, presence: true, uniqueness: true
  validates :user_id, presence: true, numericality: { only_integer: true }
  validate :user_exists

  # Ex09: Scope to get cuicuis ordered by number of likes
  scope :top, lambda {
    joins('LEFT OUTER JOIN likes ON likes.cuicui_id = cuicuis.id')
      .group('cuicuis.id')
      .order('COUNT(likes.id) DESC')
  }

  private

  def user_exists
    return if user_id.nil?

    errors.add(:user_id, 'must exist') unless User.exists?(user_id)
  end
end
