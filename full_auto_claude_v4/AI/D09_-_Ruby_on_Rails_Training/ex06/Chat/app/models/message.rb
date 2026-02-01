class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chatroom

  after_create_commit :broadcast_message
  after_create_commit :broadcast_notification

  private

  def broadcast_message
    MessageBroadcastJob.perform_later(self)
  end

  def broadcast_notification
    NotificationBroadcastJob.perform_later(self)
  end
end
