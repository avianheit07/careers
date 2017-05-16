module.exports = 
  # List all positions created, filtered by company
  list: (req, res) ->
    id        = req.session.passport.appuser
    Utils.getCompany req.session.passport, (companyId) ->
      roomPath  = [
        "position/list"
        "position/#{companyId}/company"
        "position/#{id}/user"
      ]
      if req.param('id') is 'self'
        Position.find api_user: id, (err, positions) ->
          if req.isSocket
            Broadcast.join req.socket, roomPath

          res.json positions 
      else
        UserCompany.find({api_company: companyId}).exec (err, result) ->
          if result.length and result.length isnt 0
            userIds = result.map (data) ->
              return data.api_user
            Position.find api_user: userIds, (err, positions) ->
              if req.isSocket
                Broadcast.join req.socket, roomPath
                res.json positions
              else
                res.json positions if positions
                res.json err if err
          else
            res.json []
            res.json err if err

  create: (req, res) ->
    data    = req.body
    id      = parseInt(req.session.passport.appuser)

    Utils.getCompany req.session.passport, (company) ->
      broadcastRooms = [
        "position/#{company}/company"
        "position/#{id}/user"
        "position/list"
      ]
      if req.method?
        if !data.id?
          data.api_user = +id
          Position.create data
          .exec (err, result) ->
            unless err
              if req.isSocket
                Broadcast.all broadcastRooms, result
                
              res.json result
        else
          id     = data.id
          Position.update
            id: data.id
            , data, (err, result) -> 
              if err
                return

              if req.isSocket
                Broadcast.all broadcastRooms, result

                res.json result
  remove: (req, res) ->
    postId         = req.param 'id'
    user           = req.session.passport.appuser

    Utils.getCompany req.session.passport, (company) ->
      broadcastRooms = [
        "position/#{company}/company"
        "position/#{user}/user"
        "position/list"
      ]
      # -> For local testing
      Position.destroy id: postId
      .exec (err, result) ->
        response = null
        if err
          return

        if result.length > 0
          result[0].method = 
            method: "DELETE"
            index: +req.param 'index'
          response = result[0]
          Broadcast.all broadcastRooms, response

        res.json response