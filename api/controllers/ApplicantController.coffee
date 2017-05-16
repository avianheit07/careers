Groles =
  hr: 1
  requester: 2
  admin: 3
fs = require "fs"
module.exports =
  list: (req, res) ->
    Utils.getCompany req.session.passport, (company) ->
      broadcastRooms = [
        "applicant/list"
      ]

      # Application.find({status: 1}).populate('recruitmentAd').populate('applicant').exec (err, result) ->
      Application
      .find({api_company: company, status: {'!': 0}})
      .populate('recruitmentAd')
      .populate('applicant', sort: 'createdBy DESC')
      .populate('processes', sort:'index ASC')
      .exec (err, result) ->
        RecruitmentAd.find({status: [0,1], api_company: company}).exec (err, resRec) ->
          resRec.forEach (row) ->
            if broadcastRooms.indexOf("applicant/#{row.id}/ad") is -1
              broadcastRooms.push "applicant/#{row.id}/ad"

          respondData = []

          if req.session.passport.roles[0] isnt Groles.admin #admin
            broadcastRooms.push "applicant/#{company}/company"

          respondData = result
          Broadcast.join req.socket, broadcastRooms
          res.json respondData

  create: (req, res) ->
    data          = req.body
    recruitmentAd = data.recruitmentAd
    company       = data.companyId
    resume        = false

    method         = req.method
    broadcastRooms = [
      "applicant/list"
    ]

    delete data.recruitmentAd if method is 'POST'

    # ------- transfer to creating application
    if typeof data.resume isnt "undefined"
      resume      = data.resume
      delete data.resume
    # ----------------------------------------------------
    if method is 'POST'
      Applicant.create(data).exec (errAppl, postApp) ->
        Applicant.count().exec (err, count) ->
          if errAppl || err
            return

          if resume && postApp
            ext         = resume.fd.substr((Math.max(0, resume.fd.lastIndexOf(".")) || Infinity) + 1)
            newName     = "#{postApp.firstName}_#{postApp.lastName}_#{count}"
            newLocation = __dirname + "/../../.tmp/resume/#{newName}.#{ext}"
            fs.rename resume.fd, newLocation, (errRename) ->

              unless errRename
                toSave =
                  name: newName
                  extension: ext
                  size: resume.size
                  applicant: postApp.id

              Resume.create(toSave).exec (errRes, resume) ->
                Utils.codeGen (code) ->
                  application =
                    recruitmentAd: null
                    applicant: postApp.id
                    code: code
                    ad_answer: null
                    api_company: company
                    resume: resume.id

                  if recruitmentAd? # not wildcard create application
                    delete recruitmentAd.applicants
                    application.recruitmentAd = recruitmentAd.id
                    application.ad_answer     = postApp.question.answer
                    application.api_company   = recruitmentAd.api_company
                    broadcastRooms.push "applicant/#{recruitmentAd.id}/ad"
                    broadcastRooms.push "applicant/#{recruitmentAd.api_company}/company"

                  if company? # not empty
                    broadcastRooms.push "applicant/#{company}/company"

                  Application.create(application).exec (err, resAppl) ->
                    if err
                      console.log 'err', err
                      return

                    if recruitmentAd? # not wildcard create application
                      resAppl.recruitmentAd = recruitmentAd
                    Broadcast.all broadcastRooms, resAppl
                    res.json resAppl
          else
            Applicant.destroy(postApp.id).exec (err, result) ->
              return
    else
      # If method is PUT then check if payload has recruitmentAd
      # If payload has recruitmentAd then it means it is from general application referred to a specific ad
      if data.recruitmentAd?
        broadcastRooms.push "applicant/#{recruitmentAd.id}/ad"
        broadcastRooms.push "applicant/#{recruitmentAd.api_company}/company"

        data.recruitmentAd = recruitmentAd.id
        data.resume        = resume
        Application.update(data.id, data).exec (error, resAppl) ->
          res.serverError error if error
          if resAppl[0]
            resAppl[0].recruitmentAd = recruitmentAd
            resAppl[0].method = 'PUT'
            Broadcast.all broadcastRooms, resAppl[0]
            res.json resAppl[0]

      else
        Applicant.update {id: data.id}
        , data, (err, result) ->
          if err
            return

          if result
            Broadcast.all broadcastRooms, result

          res.json result

  update: (req, res) ->
    applicationData = req.body
    broadcastRooms  = [
      "applicant/list"
    ]
    if !applicationData.processes?
      applicationData.processes = []

    delete applicationData.applicant.application

    Applicant.update id: applicationData.applicant.id
    , applicationData.applicant, (err, applicant) ->
      if err
        console.log err, "err aplicant create"
        return

      if applicant.length > 0
        if applicationData.recruitmentAd isnt null
          broadcastRooms.push "applicant/#{applicationData.recruitmentAd.id}/ad"
          broadcastRooms.push "applicant/#{applicationData.recruitmentAd.api_company}/ad"
        else
          broadcastRooms.push "applicant/#{applicationData.api_company}/company"



        if applicationData.applicant.status is 1 and applicationData.processes.length is 0
          toCreate =
            application: applicationData.id
            index: 0
            processData: applicationData.recruitmentAd.process_filter[0]
            remark: null
            status: 0
          Process.create toCreate
          .exec (err, created) ->
            if err
              console.log err
              return

            if created
              applicationData.processes.push created

            Broadcast.all broadcastRooms, applicationData
            res.json applicationData

        else if applicationData.applicant.status is 2
          applicant     = applicationData.applicant
          recruitmentAd = applicationData.recruitmentAd
          temp          = applicationData
          Application.update id: applicationData.id
          , temp, (err, application) ->
            if err
              console.log err, "else if err"
              return

            if application.length > 0
              applicationData.recruitmentAd = recruitmentAd
              applicationData.applicant     = applicant
              Broadcast.all broadcastRooms, applicationData
              res.json applicationData
        else
          applicant     = applicationData.applicant
          recruitmentAd = applicationData.recruitmentAd
          temp          = applicationData
          Application.update temp.id, temp
          .exec (error, result) ->
            res.serverError error if error
            if result[0]
              applicationData.applicant     = applicant
              applicationData.recruitmentAd =recruitmentAd
              Broadcast.all broadcastRooms, applicationData
              res.json applicationData
            else
              res.json {}

  apply: (req, res) ->
    data               = req.body
    recruitmentAd      = data.recruitmentAd
    data.recruitmentAd = recruitmentAd.id
    broadcastRooms     = [
      "applicant/list"
      "applicant/#{recruitmentAd.id}/ad"
      "applicant/#{recruitmentAd.api_company}/company"
    ]
    Utils.codeGen (code) ->
      data.code = code
      Application.create(data).exec (err, result) ->
        if err
          return
        if result
          Broadcast.all broadcastRooms, result.applicant
        res.json result.applicant

  show: (req, res) ->
    id = req.param "id"
    Application.find({recruitmentAd: id}).populate('recruitmentAd').populate('applicant').exec (err, result) ->
      res.json result

  remove: (req, res) ->
    console.log 'remove'

  tracker: (req, res) ->
    code = req.param 'code'
    Application.findOne(code:code)
    .populate('recruitmentAd')
    .populate('applicant')
    .populate('processes', sort:'index DESC')
    .exec (err, result) ->
      if !err and result
        Position.findOne(result.recruitmentAd.position)
        .exec (error, data) ->
          if !err and data
            result.recruitmentAd.position = data
            res.json result
          else
            res.json error if error
            res.json {} if !data
      else
        res.json err if err
        res.json {} if !result

  reprocess: (req, res) ->
    data = req.body
    Utils.codeGen (code) ->
      application =
        code          : code
        status        : 4
        recruitmentAd : data.reprocess.id
        applicant     : data.applicant.id
        api_company   : data.api_company
        resume        : data.resume
      # Create new application for applicants that are reprocessed
      Application.create(application).exec (err, result) ->
        return res.serverError err if err
        result.recruitmentAd = data.reprocess
        Broadcast.all "applicant/#{application.recruitmentAd}/ad", result
        update =
          id             : data.id
          status         : 3
          newApplication : result.id
          applicantData  : data.applicant
        # Update application to status 3 and add newApplication id to link to new application
        Application.update(data.id, update).exec (error, resAppl) ->
          res.serverError error if error
          room = [ "applicant/#{data.recruitmentAd.id}/ad" ]
          Broadcast.all room, resAppl[0]
          res.json resAppl[0]

  reply: (req, res) ->
    id = req.param 'id'
    answer = req.query.answer
    Application.findOne(id)    
    .populate('recruitmentAd')
    .populate('applicant')
    .exec (err, result) ->
      res.serverError err if err
      if answer is 'yes'
        process =
          application   : result.id
          index         : 0
          processData   : result.recruitmentAd.process_filter[0]
          remark        : null
          status        : 0

        # Create process if applicant replies yes
        Process.create(process).exec (error, create) ->
          res.serverError error if error
          result.processes = create
          room = [ "applicant/#{result.recruitmentAd.id}/ad"]
          Broadcast.all room, result

      else if answer is 'no'
        # Trash new application if applicant replies no
        Application.update(id, status: 3).exec (error, update) ->
          res.serverError error if error
          if update[0]
            room = [ "applicant/#{update.recruitmentAd}/ad" ]
            Broadcast.all room, update[0]