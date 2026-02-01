# frozen_string_literal: true

class User < ApplicationRecord
  # Exercise 03: Active Record Associations
  has_many :cuicuis, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # Exercise 05: Validations
  validates :name, presence: true, uniqueness: true, length: { minimum: 2 }
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :since, presence: true
  validates :country, presence: true
  validate :name_not_banned

  # Exercise 07: Model Methods

  # Returns the sum of all likes given to all user's tweets
  def fame
    cuicuis.joins(:likes).count
  end

  # Returns true if the user has been registered for more than 10 years
  def senior?
    return false unless since

    since <= Time.current.year - 10
  end

  # Returns true if the user has been registered for less than 10 years
  def junior?
    return true unless since

    since > Time.current.year - 10
  end

  # Lists the last 5 comments on the user's tweets (by creation date)
  def responses
    Comment.where(cuicui_id: cuicuis.pluck(:id))
           .order(created_at: :desc)
           .limit(5)
  end

  # Lists the user's tweets sorted by number of likes (descending)
  def top_tweet
    cuicuis.left_joins(:likes)
           .group(:id)
           .order('COUNT(likes.id) DESC')
  end

  private

  def name_not_banned
    banned_names = ['42', 'lancelot du lac', 'Ruby']
    return unless banned_names.include?(name)

    errors.add(:name, "#{name} is banished")
  end
end
