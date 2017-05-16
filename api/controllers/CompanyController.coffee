socket_listRoom = "company/list"
module.exports =
  list: (req, res) ->
    query = 
      q: internal: true
    Api 'GET', '/company/search?', query, (err, result) ->
      if req.isSocket
          sails.sockets.join req.socket, socket_listRoom
        if Array.isArray(result) is true
          return res.json result
        else
          return res.json result.rows
      return res.json result

    # -> For local testing
    # if req.isSocket
    #   sails.sockets.join req.socket, 'company/list'
    # else
    #   Branch.find().exec (err, result) ->
    #     res.json result

  show: (req, res) ->
    id = req.param "id"
    if req.param("id") is "self"
      Utils.getCompany req.session.passport, (company) ->
        res.json {company_id: company}
    else
      Api "GET", "/appuser/show/#{id}", (err, result) ->
        if err
          console.log "error"
        else
          res.json result


  create: (req, res) ->
    api_data          = req.body
    api_data.internal = true
    api_method        = "POST"
    api_url           = "/company/create"

    if req.method?
      if req.method is "PUT"
        id         = api_data.id
        api_method = "PUT"
        api_url    = "/company/update/#{id}"

    Api api_method, api_url, api_data, (err, result) ->
      unless err and result
        Broadcast.all socket_listRoom, result
        res.json result
      else
        res.json null

    # -> For local testing
    # Branch.create data
    # .exec (err, result) ->
    #   unless err and result
    #     sails.sockets.broadcast 'company/list', 'company/list', result
    #     res.json result
    #   else
    #     res.json null

  remove: (req, res) ->
    id = +req.param 'id'
    Api "DELETE", "/company/remove/#{id}", (err, result) ->
      resData = undefined

      if result
        result.method =
          method: "DELETE"
          index: +req.param 'index'

        resData = result

      Broadcast.all socket_listRoom, resData
      res.json resData

    # -> For local testing
    # Branch.destroy id: id
    # .exec (err, result) ->
    #   result[0].method =
    #     method: "DELETE"
    #     index: +req.param 'index'
    #   sails.sockets.broadcast "company/list", "company/list", result[0]
    #   res.json result
  # get: (req, res) ->
  #   id = req.param 'id'
  #   if id is 'self'
  #     id = req.session.passport.appuser
  #   else
  #     id = null

  #   UserCompany.findOne id: id
  #   .exec (err, result) ->
  #     if result
  #       res.json result
  #     else
  #       res.json null