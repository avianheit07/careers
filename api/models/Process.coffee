Process = 
  adapter: "mongo"
  schema: true
  attributes:
    application: 
      type: "string"
      model: "Application"
    index: "integer"
    processData: "object"
    remark: "string"
    status: 
      type: "integer"
      defaultsTo: 0

  afterCreate: (value, next) ->
    Application.findOne(value.application)
    .populate('applicant')
    .exec (err, result) ->
      if result and !err
        RecruitmentAd.findOne(result.recruitmentAd)
        .populate('position')
        .exec (error, data) ->
          if data and !error
            host = Host.url
            text = "Your application for #{data.position.title} is now being processed."
            text += "<br> For more information visit this <a href='#{host}/tracker/#{result.code}'>link</a>."
            mail = 
              subject: data.position.title + ' Application'
              html: text
              to: 
                name: result.applicant.firstName + ' ' + result.applicant.lastName
                address: result.applicant.email
            Email.sendMail mail
            next()
          else
            next()
      else
        next()

module.exports = Process

###
  NOTES:
    type -> 0 - manual filter, 1 - exam filter, 2 - interview filter
    status -> 0 - unprocesed, 1 - recommended, 2 - unrecommended
    sample: 
      if type is 0
        processData: {
          name: 'string'
          description: 'string'
          inCharge: 'integer' -> user id
        }
      if type is 1
        {
          name: 'string'
          description: 'string'
          inCharge: 'integer' -> user id
          score: 'integer'
        }
      if type is 2
        {
          name: 'string'
          description: 'string'
          inCharge: 'integer' -> user id
          interviewNotes: [
            {
              question: 'string'
              answer: 'string'
            }
            ...
          ]
        }
###