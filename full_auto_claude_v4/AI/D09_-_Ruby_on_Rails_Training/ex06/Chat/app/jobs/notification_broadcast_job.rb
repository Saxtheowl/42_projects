class NotificationBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    User.all.each do |user|
      if user.id != message.user_id
        ActionCable.server.broadcast "notifications_#{user.id}",
          notification: "New message from #{message.user.email} in #{message.chatroom.name}"
      end
    end
  end
end
