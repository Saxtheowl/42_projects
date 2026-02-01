# frozen_string_literal: true

# User model representing users in the tweetos application
class User < ActiveRecord::Base
  BANISHED_NAMES = %w[42 Ruby].freeze
  BANISHED_NAMES_WITH_SPACES = ['lancelot du lac'].freeze

  has_many :cuicuis, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { minimum: 2 }
  validates :email, presence: true, uniqueness: true,
                    format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :since, presence: true
  validates :country, presence: true
  validate :name_not_banished

  # Ex07: Returns the total number of likes on all user's cuicuis
  def fame
    cuicuis.joins(:likes).count
  end

  # Ex07: Returns true if user has been registered for more than 10 years
  def senior?
    return false if since.nil?

    since <= Time.now.year - 10
  end

  # Ex07: Returns true if user has been registered for less than 10 years
  def junior?
    !senior?
  end

  # Ex07: Returns the 5 most recent comments on user's cuicuis
  def responses
    Comment.where(cuicui_id: cuicuis.pluck(:id))
           .order(created_at: :desc)
           .limit(5)
  end

  # Ex07: Returns user's cuicuis sorted by number of likes
  def top_cuicui
    cuicuis.joins('LEFT OUTER JOIN likes ON likes.cuicui_id = cuicuis.id')
           .group('cuicuis.id')
           .order('COUNT(likes.id) DESC')
  end

  private

  def name_not_banished
    return if name.nil?
    return unless BANISHED_NAMES.include?(name) || BANISHED_NAMES_WITH_SPACES.include?(name)

    errors.add(:name, "#{name} is banished")
  end
end
