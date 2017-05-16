Position = 
  adapter: "mongo"
  migrate: "safe"
  schema: true
  attributes:
    title: "string"
    description: "string"
    responsibility: "array"
    education: "array"
    skill: "array"
    other: "array"
    note: "string"
    process_filter: "array"
    api_user: "integer"


module.exports = Position

###
  NOTES:
    *_requirements: [
      {
        requirement: 'string'
      }
      {
        requirement: 'string'
      }
      ...
    ]

    process_filter: [
      {
        name: 'string'
        description: 'string'
        inCharge: 'integer' -> user id
        index: 'integer'
        type: 0 - manual
      }
      ...
      {
        name: 'string'
        description: 'string'
        inCharge: 'integer' -> user id
        index: 'integer'
        passingScore: 'integer'
        type:  1 - exam
      }
      ...
      {
        name: 'string'
        description: 'string'
        inCharge: 'integer' -> user id
        index: 'integer'
        interviewNotes: 'array'
        type: 2 - interview
      }
    ]

    interviewNotes: [
      {
        question:
      }
      {
        question:
      }
      ...
    ]
###