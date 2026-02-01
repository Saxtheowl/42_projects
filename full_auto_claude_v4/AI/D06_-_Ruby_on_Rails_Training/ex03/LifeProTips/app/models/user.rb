class User < ActiveRecord::Base
  has_secure_password

  has_many :posts, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :edited_posts, class_name: 'Post', foreign_key: 'edited_by_id'

  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }
  validates :password, length: { minimum: 8 }, if: :password_required?

  def total_votes_received
    Vote.joins(:post).where(posts: { user_id: id }).sum(:value)
  end

  def can_upvote?
    total_votes_received >= 3
  end

  def can_downvote?
    total_votes_received >= 6
  end

  def can_edit_posts?
    total_votes_received > 9
  end

  def privileges
    result = []
    result << 'upvote' if can_upvote?
    result << 'downvote' if can_downvote?
    result << 'edit_posts' if can_edit_posts?
    result.empty? ? ['none'] : result
  end

  private

  def password_required?
    password_digest.blank? || password.present?
  end
end
