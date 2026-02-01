App.chat = App.cable.subscriptions.create "ChatChannel",
  connected: ->

  disconnected: ->

  received: (data) ->
    $('#messages').append data['message']
