kue        = require 'kue'
jobs       = kue.createQueue({
  prefix: 'q',
  redis: 
    port: process.env.REDIS_PORT_6379_TCP_PORT || 6379
    host: process.env.REDIS_PORT_6379_TCP_ADDR || 'localhost'
})
nodemailer = require 'nodemailer'

mail = nodemailer.createTransport(
  service: 'gmail'
  auth:
    user: 'training.you@meditab.com'
    pass: 'welcome@123'
)
createJob = (data) ->
  job = jobs.create('email', data).attempts(5)
  .save()
  .on 'complete', ->
    job.data.status = 1
    FailedEmail({id: job.data.id}, job.data)
    .exec (err, complete) ->
  .on 'failed', ->
    job.data.status = 2
    FailedEmail
    .update({id: job.data.id}, job.data)
    .exec (err, failed) ->

  jobs.process 'email', 10, (job, done) ->
    mail.sendMail job.data, (err, info)->
      if err
        done(new Error(err))
      else if info
        done()

Mail =
  sendMail: (data) ->
    mail.sendMail(data, (err, info) ->
      if err
        failedData = 
          content: data.html
          subject: data.subject
          recipient: data.to
          sentAt: new Date()
          status: 0
        FailedEmail.create(failedData)
        .exec (error, failedRes) ->
          createJob(failedRes) if failedRes
    )
module.exports = Mail