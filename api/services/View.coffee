roles =
  hr: 1
  requester: 2
  admin: 3
View =
  render: (req, res) ->
    base      = req.headers.host
    user_data = req.session
    if user_data.passport.appuser
      if user_data.passport.roles.length is 1
        length = user_data.passport.roles.length - 1
        switch user_data.passport.roles[length].roleId
          when roles.admin
            res.view "admin",{base:base}
          when roles.hr
            res.view "hr",{base:base}
          when roles.requester
            res.view "requester",{base:base}
          else
            res.view "public",{base:base}
      else
        res.view "public",{base:base}
    else
      res.view "public",{base:base}

module.exports = View