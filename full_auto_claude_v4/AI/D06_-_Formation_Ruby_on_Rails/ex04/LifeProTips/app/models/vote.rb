class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  validates :user_id, presence: true
  validates :post_id, presence: true
  validates :value, presence: true, inclusion: { in: [-1, 1] }
  validates :user_id, uniqueness: { scope: :post_id, message: 'has already voted on this post' }

  def voter_name
    user&.name || 'Unknown'
  end

  def post_title
    post&.title || 'Unknown'
  end
end
