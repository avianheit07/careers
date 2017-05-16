passport = require 'passport'

module.exports =
  index: (req, res) ->
    View.render req, res

  login: (req, res) ->
    data = req.body
    # Traditional login (username and password)
    data.strategy = 'local'
    # Call api service
    Api('POST', '/user/authenticate', data, (err, result) ->
      unless result.appuser is undefined
        req.session.passport = result
        if req.session.passport.roles.length is 0
          req.session.passport = {}
        res.redirect '/'
      else res.redirect '/login'
    )

  oauth: (req, res) ->
    passport.authenticate('google',
      scope: [
        'https://www.googleapis.com/auth/userinfo.email'
        'https://www.googleapis.com/auth/userinfo.profile'
        'https://www.googleapis.com/auth/plus.login'
      ], (err, user, info) ->
        return res.redirect '/' if err
        req.session.passport = user
        if req.session.passport.roles.length is 0
          req.session.passport = {}
        return res.redirect '/'
    ) req, res

  logout: (req, res) ->
    req.logout
    req.session.destroy()
    res.redirect '/login'