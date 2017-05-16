module.exports =
  adapter: 'mongo'
  schema: true
  attributes: 
    firstName: "string"
    lastName: "string"
    telephoneNumber: "string"
    mobileNumber: "string"
    email: 
      type: "string"
      unique: true
      required: true
    expectedStart: "string"
    application:
      collection: "application"
      via: "applicant"
    question: "object"
    status: 
      type: "integer"
      defaultsTo: 0
    hiredAt: 
      type: "date"
      defaultsTo: null

###
  NOTE:
    resume -> 0 - false / 1 - true
    staues -> 0 -> new / 1 - verified / 2 - unverified
###