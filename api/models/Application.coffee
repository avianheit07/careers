Application = 
  adapter: "mongo"
  schema: true
  attributes:
    recruitmentAd:
      type: "string"
      model: "RecruitmentAd"
    applicant:
      type: "string"
      model: "Applicant"
    code: 
      type: "string"
      required: true
    ad_answer: "string"
    processes:
      collection: "process"
      via: "application"
    status: 
      type: "integer"
      defaultsTo: 1
    deletedAt: 
      type: "date"
      defaultsTo: null
    api_company: "integer"
    resume:
      type: "string"
      model: "Resume"
    newApplication: # Id of new application if applicant is reprocessed
      type: 'string'
      model: 'Application'

  afterCreate: (value, next) ->
    Applicant.findOne(id:value.applicant)
    .exec (errApp, result) ->
      if result and !errApp
        value.applicant = result
        # Sends email to applicants first when status is 4
        # When applicants accepts reprocessing it is directly changed to the process filter
        if value.status is 4
          host = Host.url
          message = 'Your application has been reprocessed. <br/>'
          message += "Click <a href='#{host}/reprocessed/#{value.id}?answer=yes'>this link</a> if you agree. <br/>"
          message += "Click <a href='#{host}/reprocessed/#{value.id}?answer=no'>this link</a> if you don't."
          mail =
            subject: 'Reprocess application'
            html: message
            to: 
              name: result.firstName + ' ' + result.lastName
              address: result.email
          Email.sendMail(mail)
          next()
          
        if value.recruitmentAd?
          RecruitmentAd.findOne(value.recruitmentAd)
          .populate('position')
          .exec (errRecruit, data) ->
            if data and !errRecruit and value.status is 1
              host = Host.url
              text = 'You can track your application using this '
              text += "<a href='#{host}/tracker/#{value.code}'>link</a>"
              subject = 'Medspecialized Application'
              mail = 
                subject: subject
                html: text
                to:
                  name: result.firstName + ' ' + result.lastName
                  address: result.email
              Email.sendMail(mail)
              next()
            else next()
        else next()
      else
        next()    
        
module.exports = Application

###
Status: 0 - inactive, 1 - active, 2 - done, 3 - trash, 4 - reprocessed
###