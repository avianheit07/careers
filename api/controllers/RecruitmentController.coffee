Groles =
  hr: 1
  requester: 2
  admin: 3

module.exports =
	list: (req, res) ->
    unless req.query.appuser?
      companyId = parseInt req.param 'id'
      role     = req.session.passport.roles
      id       = req.session.passport.appuser
      Utils.getCompany req.session.passport, (company) ->
        company = if company? then company else companyId
        query          = {}
        broadcastRooms = [
          "recruitment/#{id}/user"
          "recruitment/#{company}/company"
        ]
        if req.isSocket
          if role?
            switch role[role.length-1].role
              when Groles.admin
                sails.sockets.join req.socket, "recruitment/list"
              else
                query.api_company = company
                Broadcast.join req.socket, broadcastRooms
          else
            query.api_company = company
            Broadcast.join req.socket, broadcastRooms

          RecruitmentAd.find(query)
          .populate('position')
          .populate('applicants')
          .sort('weight DESC')
          .sort('createdAt DESC')
          # RecruitmentAd.find(query).populate('position')
          .exec (err, result) ->
            # if result and !err
            #   Broadcast.all broadcastRooms, result
            if err
              console.log err, 'err'

            res.json result
    else
      id  = parseInt req.query.appuser
      ids = []

      # Query through position wich requester has responsibility
      Position.find(process_filter:{$elemMatch:{'assigned.id':id}})
      .exec (err, result) ->
        if result.length isnt 0
          # Map through result and get ids
          ids = result.map (value) ->
            return value.id
        RecruitmentAd.find(or:[{api_user:id},{position:ids}])
        .populate('position')
        .populate('applicants', sort: 'createdBy DESC')
        .exec (error, recruitRes) ->
          rooms = [
            "recruitment/#{id}/user"
          ]
          if req.isSocket
            Broadcast.join req.socket, rooms
            res.json recruitRes
      # Process.find('processData.assigned.id':id)
      # .populate('application')
      # .exec (err, result) ->
      #   # Map through the results to get the id
      #   # then, filter all unique ids and assign to variable ids
      #   if result.length isnt 0
      #     ids = result.map((value) ->
      #       return value.application.recruitmentAd
      #     ).filter((val, i, arr) -> return arr.indexOf(val) is i)
      #   RecruitmentAd.find(or:[{api_user:id},{id:ids}])
      #   .populate('position')
      #   .populate('applicants')
      #   .exec (error, recruitRes) ->
      #     rooms = [
      #       "recruitment/#{id}/user"
      #     ]
      #     if req.isSocket
      #       # console.log recruitRes
      #       Broadcast.join req.socket, rooms
      #       res.json recruitRes

  show: (req, res) ->
    # Populate RecruitmentAd based on passed id
    id      = req.param 'id'     
    company = req.session.passport.company
    broadcastRooms = [
      "recruitment/#{id}/user"
      "recruitment/#{company}/company"
    ]
    Broadcast.join req.socket, broadcastRooms

    RecruitmentAd.findOne(id)
    .populate('position')
    .populate('applicants', sort: 'createdBy DESC')
    .sort('weight DESC')
    .sort('createdAt DESC')
    .exec (err, result) ->
      return res.serverError err if err
      return res.json {} if !result
      if result
        Broadcast.join req.socket, "applicant/#{result.id}/ad"
        # console.log result
        applicationIds = result.applicants.map (value) ->
          return value.id
        Application.find(applicationIds)
        .populate('applicant')
        .populate('processes', sort:'index ASC')
        .exec (error, resAppl) ->
          if resAppl.length isnt 0 and !error
            applicants = result.applicants.map (val) ->
              val.processes = []
              filter = resAppl.filter (data) ->
                # Check if result.applicants[i].id is equal to the resAppl[i].id
                if val.id is data.id
                  return data
              # Assign filtered result to val
              val = filter[0]
              return val
            # Clone deep to assign processess to the result
            clone = _.cloneDeep(result)
            clone.applicants = applicants
            res.json clone
          else
            res.serverError error if error
            res.json result

	create: (req, res) ->
    id              = req.session.passport.appuser
    data            = req.body
    Utils.getCompany req.session.passport, (company) ->
      broadcastRooms = [
        "recruitment/list"
        "recruitment/#{company}/company"
        "recruitment/#{id}/user"
      ]
      data.api_company = company
      data.requestDate = new Date()
      if data.process_filter.length isnt 0
        data.process_filter.map (value) ->
          broadcastRooms.push "recruitment/#{value.assigned.id}/user"
      RecruitmentAd.create data
      .exec (err, result) ->
        if result and !err
          Broadcast.all broadcastRooms, result

        res.json result

  update: (req, res) ->
    id              = req.param "id"
    userid          = req.session.passport.appuser
    data            = req.body
    applicants      = data.applicants
    method          = req.method
    delete data.applicants # Delete applicants key; creates error when sorting recruitmentAd
    Utils.getCompany req.session.passport, (company) ->
      broadcastRooms = [
        "recruitment/list"
        "recruitment/#{company}/company"
      ]

      if method? and method is "DELETE"
        data.deletedAt = new Date()

      RecruitmentAd.update
        id: data.id
        , data
        , (err, result) ->
          if result[0] and !err
            result[0].method = 'UPDATE'
            Broadcast.all broadcastRooms, result[0]

            res.json result[0]
          else 
            return res.serverError err if err
            res.json []

  counter: (req, res) ->
    RecruitmentAd.find().exec (err, result) ->
      return es.serverError err if err
      count = 0
      result.forEach (value) ->
        count += parseInt(value.quota)
      Broadcast.join req.socket, "recruitment/list"
      res.json count:count