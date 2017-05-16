app.factory "USER",[
  "$resource"
  ($r) ->
    USER = $r("/user/:listAction:idAction/:id", {id:"@id"},{
      list:
        method: "get"
        params:
          idAction: "list"
        isArray: true
        cache: true
      show:
        method: "get"
        params:
          idAction: "show"
        isArray: true
        cache: true
      create:
        method: "post"
        params:
          idAction: "create"
        isArray: false
      update:
        method: "put"
        params:
          idAction:"update"
        isArray: false
      hr:
        method: "get"
        params:
          listAction: "hr"
        isArray: true
        cache: true
      requester:
        method: "get"
        params:
          listAction: "requester"
        isArray: true
        cache: true
    })
]

app.factory "COMPANY",[
  "$resource"
  ($r) ->
    COMPANY = $r("/company/:listAction:idAction/:id", {id:"@id"},{
      list:
        method: "get"
        params:
          idAction: "list"
        isArray: true
        cache: true
      show:
        method: "get"
        params:
          idAction: "show"
        isArray: true
        cache: true
      create:
        method: "post"
        params:
          idAction: "create"
        isArray: false
      update:
        method: "put"
        params:
          idAction:"update"
        isArray: false

    })
]