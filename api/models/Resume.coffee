Resume = 
  adapter: "mongo"
  schema: true
  attributes:
    name: "string"
    extension: "string"
    size: "string"
    applicant: "applicant"
    application: 
      collection: "application"
      via: "resume"
