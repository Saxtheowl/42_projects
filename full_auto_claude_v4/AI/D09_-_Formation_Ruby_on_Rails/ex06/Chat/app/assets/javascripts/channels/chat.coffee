$(document).on 'turbolinks:load', ->
  messagesDiv = $('#messages')
  if messagesDiv.length > 0
    chatroomId = messagesDiv.data('chatroom-id')
    if chatroomId
      App.chat = App.cable.subscriptions.create { channel: "ChatChannel", chatroom_id: chatroomId },
        connected: ->

        disconnected: ->

        received: (data) ->
          $('#messages').append data['message']
