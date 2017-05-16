Broadcast =
  all: (rooms, data) ->
    response = false
    if Array.isArray(rooms) and rooms.length > 0
      rooms.forEach (room) ->
        if typeof room is "string"
          sails.sockets.broadcast room, room, data
        else
          sails.sockets.broadcast room.name, room.name, room.data

      response = true
    else if typeof rooms is "string"
      sails.sockets.broadcast rooms, rooms, data
      response = true
    else
      console.log "Invalid data"

    return response

  join: (socket, rooms) ->

    if Array.isArray(rooms) and rooms.length > 0
      rooms.forEach (room) ->
        if typeof room is "string"
          sails.sockets.join socket, room

        else
          sails.sockets.join socket, room.name
    else if typeof rooms is "string"
      sails.sockets.join socket, rooms

    else
      console.log "Invalid room to join"

    return
  test: () ->
    console.log "broadcast test is called"
module.exports = Broadcast