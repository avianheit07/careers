Groles =
  "hr": 1
  "requester": 2
  "admin": 3

module.exports =
  search: (req, res) ->
    if req.param('search')?
      query = 
        q:
          email: 
            contains: "#{req.param('search')}"
          userType: 0
      Api('GET',"/appuser/search?", query, (err, result)->
        if Array.isArray(result)
          res.json result
        else
          res.json result.rows
      )

  password: (req, res) ->
    data    = req.body
    data.id = req.session.passport.appuser
    if data
      Api('POST','/user/password', data, (err, result) ->
        unless err
          res.json result
        else
          res.json err

      )
  role: (req, res) ->
    data_role = req.param "role"
    roleId    = Groles["#{data_role}"]
    id        = +req.param "id"
    company   = req.param "companyId"

    Utils.getCompany req.session.passport, (companyRes) ->
      if !company?
        company = companyRes
      else
        if typeof company is 'object'
          company = company.company_id

      broadcastRooms = [
        "user/#{data_role}"
        "user/#{company}/#{data_role}"
        "user/#{company}/company"
        "user/list"
      ]
      # return console.log broadcastRoomsZ
      if req.isSocket and req.method# sockets
        switch req.method
          when "DELETE" 
            user = req.param 'id'
            role = req.param 'role'
            query = 
              q:
                appuserId: user, roleId: roleId
            Api "GET", "/userrole/search?", query, (err, roleSearch) ->
              userToRemove = roleSearch[0]

              Api "DELETE", "/userrole/remove/#{userToRemove.id}", (err, deleted) ->
                resData = {}
                if deleted
                  UserCompany.destroy {api_user: userToRemove.appuserId}
                  .exec (err, destroyed) ->
                  deleted.method = 
                    method: "DELETE"

                resData = deleted
                Broadcast.all broadcastRooms, resData
                res.json resData
          else
            api_data =
              appuserId: id
              roleId: roleId
            toCreate = 
              api_user: id
              api_company: company

            query = 
              q: 
                appuserId: id
                roleId: [1,2,3]

            # Check if user has an existing role in the API
            Api 'GET', '/userrole/search?', query, (err, result) ->
              userExisting = result[0]

              # Get data of the user from the api
              Api "GET", "/appuser/show/#{id}", (err, user) ->
                # toCreate.api_company = user.companyId if user
                UserCompany.findOne({api_user: id}).exec (err, resSearch) ->
                  user.company_id = company if resSearch

                  if userExisting # User has a role in the API
                    Api "PUT", "/userrole/update/#{userExisting.id}", api_data, (err, created) ->
                      if created
                        if resSearch # if found, update
                          resSearch.api_company = company
                          UserCompany.update({id: resSearch.id}, resSearch).exec (err, updated) ->
                            unless err and !updated
                              Broadcast.all broadcastRooms, user
                              res.json user
                        else # not found, create new
                          UserCompany.create(toCreate).exec (err, result) ->
                            unless err and !result
                              Broadcast.all broadcastRooms, user
                              res.json user
                  else # has no role in the API
                    Api "POST", "/userrole/create", api_data, (err, created) ->
                      if created
                        user.companyId = company
                        if resSearch # if found, update
                          resSearch.api_company = company
                          UserCompany.update({id: resSearch.id}, resSearch).exec (err, updated) ->
                            unless err and !updated
                              Broadcast.all broadcastRooms, user
                              res.json user
                        else # not found, create new
                          UserCompany.create(toCreate).exec (err, result) ->
                            unless err and !result
                              Broadcast.all broadcastRooms, user
                              res.json user

      else # ajax request 
        console.log 'here'
  list: (req, res) ->
    socket_listroom = "user/admin"

    if res.isSocket
      sails.sockets.join req.socket, socket_listroom
    else
      Api "GET", "/role/search?app=#{req.session.passport.token}", (err, result) ->
        if Array.isArray result is true
          Broadcast.all socket_listroom, result
          res.json result 
        else
          res.json undefined

  hr: (req, res) ->
    # Utils.getCompany req.session.passport, (company) ->
    broadcastRooms = "user/hr"
    Broadcast.join req.socket, broadcastRooms
    Utils.getAllUsers {role: Groles.hr, token: req.session.passport.token}, (result) ->
      if Array.isArray(result)
        res.json result
      else
        res.json result.rows

  requester: (req, res) ->
    Utils.getCompany req.session.passport, (company) ->
      broadcastRooms = [
        "user/requester"
        "user/#{company}/company"
        "user/#{company}/requester"
      ]
      Broadcast.join req.socket, broadcastRooms

      Utils.getAllUsers {role: Groles.requester, token: req.session.passport.token, filter: {filter: 'company', data: company}}, (result) ->
        if Array.isArray(result)
          res.json result
        else
          res.json result.rows

  session: (req, res) ->
    Utils.getCompany req.session.passport, (company) ->
      data = req.session.passport

      if company isnt null
        data.company = company

      res.json data

  show: (req, res) ->
    id = if req.param('id') is 'self' then req.session.passport.appuser else req.param('id')
    Api 'GET', "/appuser/show/#{id}", (err, result) ->
      res.json result
