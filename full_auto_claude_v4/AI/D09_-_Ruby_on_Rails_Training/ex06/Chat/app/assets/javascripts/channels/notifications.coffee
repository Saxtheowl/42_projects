$(document).on 'turbolinks:load', ->
  userIdMeta = $('meta[name="current-user-id"]')
  if userIdMeta.length > 0
    userId = userIdMeta.attr('content')
    if userId
      App.notifications = App.cable.subscriptions.create { channel: "NotificationsChannel", user_id: userId },
        connected: ->

        disconnected: ->

        received: (data) ->
          $('#notifications_list').prepend('<li>' + data.notification + '</li>')
          count = parseInt($('#notifications_count').text()) || 0
          $('#notifications_count').text(count + 1)
          audio = document.getElementById('notification_sound')
          if audio
            audio.play()
