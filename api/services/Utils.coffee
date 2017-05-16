Utils =
  getCompany: (session, cb) ->
    if session?
      UserCompany.findOne({api_user: +session.appuser}).exec (err, result) ->
        # console.log result, 'utils'
        if result
          # console.log 'if result'
          if result.api_company is session.company
            # console.log 'if result if', result.api_company
            cb +session.company
          else
            # console.log 'if result else', result.api_company
            cb +result.api_company
        else
          cb null
          # console.log 'if else', session.company
    else
      cb null
  getAllUsers: (data, cb) ->
    # data: token, role,
    allApiUsers = undefined
    allAppUsers = undefined
    resultData  = []
    query       = null
    if data.filter?
      query = data.filter

    getData     = (index) ->
      if typeof allApiUsers[index] isnt 'undefined'
        user = allApiUsers[index++]
        if user?
          toPush = false
          if typeof user.appuserId is 'object'
            idx    = allAppUsers.map( (data) -> data.api_user).indexOf(user.appuserId.id)

            if idx > -1
              user.appuserId.companyId = allAppUsers[idx].api_company

              if query?
                if user.appuserId.companyId is query.data
                  toPush = true
              else
                toPush = true

              if toPush
                resultData.push user.appuserId

        getData index
      else
        cb resultData
    qry = 
      q:
        [{roleId:data.role}]
      populate: 'appuserId'
    Api "GET", "/userrole/search?", qry, (err, resApi) ->
      UserCompany.find().exec (err, resApp) ->
        if resApi
          if resApp.length > 0
            allAppUsers = resApp
          else
            allAppUsers = []

          allApiUsers = resApi
          getData 0
        else
          cb resultData
  codeGen: (cb) ->
    code       = ""
    insertItem =  new Date().getTime().toString()
    codeLength = insertItem.length

    generate = (length, done) ->
      unless done and length > 0
        chars  = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_.~"
        i = length--
        j = 0

        while i > 0
          code += chars[Math.round(Math.random() * (chars.length - 1))]
          if insertItem[j]?
            code += insertItem[j]
            insertItem.slice(0)

          --i
        if insertItem.length > 0
          code += insertItem
        Application.findOne({code: code}).exec (err, result) ->
          if result #found
            insertItem = new Date().getTime().toString()
            generate length, false
          else
            cb code

      else
        cb code
    generate codeLength, false

module.exports = Utils