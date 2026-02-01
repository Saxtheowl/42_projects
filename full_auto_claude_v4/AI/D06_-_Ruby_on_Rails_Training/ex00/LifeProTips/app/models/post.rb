class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :editor, class_name: 'User', foreign_key: 'edited_by_id'
  has_many :votes, dependent: :destroy

  validates :user_id, presence: true
  validates :title, presence: true, uniqueness: true, length: { minimum: 3 }
  validates :content, presence: true

  default_scope { order(created_at: :desc) }

  def total_votes
    votes.sum(:value)
  end

  def author_name
    user&.name || 'Unknown'
  end

  def editor_name
    editor&.name
  end
end
