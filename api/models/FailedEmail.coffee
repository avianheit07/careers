FailedEmail = 
  adapter: "mongo"
  schema: true
  attributes:
    content: "string"
    subject: "string"
    status: 
      type: "integer" # 0 - pending, 1 - done, 2 - failed
      defaultsTo: 0
    recipient: "json"
    sentAt: "date"
