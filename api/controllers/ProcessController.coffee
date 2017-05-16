module.exports = 
  create: (req, res) ->
    applicationData = req.body
    toCreate        =
      application: applicationData.id
      index: 0
      processData: applicationData.recruitmentAd.process_filter[0]
      remark: null
      status: 0
    broadcastRooms  = [
      "application/list"
    ]
    Process.create toCreate
    .exec (err, created) ->
      if err
        return

      if created
        applicationData.processes = created
        broadcastRooms.push "applicant/#{applicationData.recruitmentAd.id}/ad"
        broadcastRooms.push "applicant/#{applicationData.recruitmentAd.api_company}/company"

      Broadcast.all broadcastRooms, applicationData
  find: (req, res) ->
    console.log 'find'
  update: (req, res) ->
    applicationData = req.body
    length          = applicationData.processes.length
    process         = applicationData.processes[length-1] # assuming data is object and it is to be updated
    applicant       = applicationData.applicant
    broadcastRooms  = [
      "applicant/list"
    ]
    # console.log process, applicationData
    Process.update {id: process.id}
    , process, (err, updated) ->
      if err
        console.log 'err', err
        return

      if updated[0]
        proceed = true

        switch process.processData.type
          when 1 # for exam
            if process.status is 2
              proceed = if process.recommend then true else false
          when 2 # for interview

          else

        recruitmentAd = applicationData.recruitmentAd
        nextIndex     = updated[0].index + 1
        # Checks if there is still existing process filter
        if applicationData.recruitmentAd.process_filter[nextIndex] isnt undefined and proceed
          processData = applicationData.recruitmentAd.process_filter[nextIndex]
          delete processData.index
          toCreate    = 
            application: applicationData.id
            index: nextIndex
            processData: processData
            remark: null
            status: 0
          Process.create toCreate
          .exec (err, created) ->
            if err 
              console.log err
              return

            if created
              applicationData.processes.push created
              broadcastRooms.push "applicant/#{recruitmentAd.id}/ad"
              broadcastRooms.push "applicant/#{recruitmentAd.api_company}/company"

            Broadcast.all broadcastRooms, applicationData
        # update application status if closed / done
        else
          applicationData.status        = if applicationData.status isnt 2 then 2 else applicationData.status
          applicationData.recruitmentAd = recruitmentAd.id
          Application.update id: applicationData.id
          , applicationData, (err, application) ->
            if err
              console.log 'error'
              return
              
            if application
              # application.method =
                # method: "DELETE"
              broadcastRooms.push "applicant/#{recruitmentAd.id}/ad"
              broadcastRooms.push "applicant/#{recruitmentAd.api_company}/company"

            applicationData.recruitmentAd = recruitmentAd
            applicationData.applicant     = applicant
            Broadcast.all broadcastRooms, applicationData