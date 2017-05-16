RecruitmentAd =
  adapter: "mongo"
  schema: true
  attributes:
    api_company: "integer"
    dueDate: "date"
    requestDate: "date"
    employmentType: "integer"
    weight: 
      type: "integer"
      defaultsTo: 0
    question: "string"
    position:
      type: "string"
      model: "Position"
    quota: "integer"
    api_user: "integer"
    salary: "object"
    status:
      type: "integer"
      defaultsTo: 0
    process_filter: "array"
    applicants: 
      collection: "application"
      via: "recruitmentAd"
    deletedAt:
      type: "date"
      defaultTo: null

  afterCreate: (value, next) ->
    Position.findOne(value.position)
    .exec (err, result) ->
      if result and !err
        value.position = result
        next()
      else
        next()

  # Checks highest weight first then adding 1
  beforeCreate: (value, next) ->
    sails.models['recruitmentad'].find()
    .limit(1)
    .sort('weight DESC')
    .exec (err, result) ->
      return res.serverError err if err
      if result[0]
        value.weight = result[0].weight + 1
        next()
      else
        next()

module.exports = RecruitmentAd

###
  NOTES:
    status -> 0 - active / 1 - closed/inactive
    employementType -> 0 - Full Time, 1 - Contractual, 2 - Fixed Term/Consultant, 3 - Part time
    sample:
      salary: {
        min: 'string'
        max: 'string'
      }
###
