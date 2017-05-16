###*
Service dependencies and variables
hawk - Api primary security created by Eran Hammer (https://github.com/hueniverse/hawk)
http - Send request to api, require https if ssl is enabled
host - ip address/host name of the api
port - port of the api if any; comment if port is 80
options - option object for the http request
credentials - Replace key and id with the generated id and key by meditab api admin
###

hawk = require("hawk")
http = require("http")
host = "api.meditab.com"
port = 80

credentials =
  id: "553f71f1ebf5d74502ffc021"
  key: "f_xByzAmV5QKTcm52euqpL-um12NX72s2Wdyx2Pi"
  algorithm: "sha256"

options =
  host: host
  port: (if port then port else 80)
  headers: {}

Error =
  statusCode: 502
  error: "Bad Gateway"
  message: "Something is wrong with the server, please contact your system administrator"
# Header generator
header = (url, method) ->
  head = hawk.client.header(url, method,
    credentials: credentials
  )
  return head.field

serialize = (obj, prefix) ->
  str = []
  for p of obj
    if obj.hasOwnProperty(p)
      k = if prefix then prefix + '[' + p + ']' else p
      v = obj[p]
      str.push if typeof v == 'object' then serialize(v, k) else encodeURIComponent(k) + '=' + encodeURIComponent(v)
  str.join '&'

# Concatenates url, parameters for the header
urlConcat = (params) ->
  # Replace http with https if ssl is enabled
  "http://" + host + ":" + port + params

module.exports = ->
  method         = arguments[0].toUpperCase()
  params         = arguments[1]
  next           = (if arguments.length <= 3 then arguments[2] else arguments[3])
  payload        = (if arguments.length > 3 then JSON.stringify(arguments[2]) else null)
  Authorization  = header(urlConcat(params), method)
  options.method = method
  options.path   = params
  options.headers.Authorization = Authorization
  if method is "GET"
    fullData = ''
    if payload?
      queryString                   = serialize JSON.parse(payload)
      newParams                     = params + queryString
      Authorization                 = header(urlConcat(newParams), method)
      options.path                  = newParams
      options.headers.Authorization = Authorization
    req = http.get(options, (response) ->
      response.setEncoding "utf8"
      response.on "data", (data) ->
        if data
          fullData += data

      response.on 'end', ->
        try
          parsedData = JSON.parse fullData
        catch
          parsedData = Error
        next null, parsedData
    )
    req.on "error", (e) ->
      next JSON.parse(e), null
    req.end()

  else
    request = http.request(options, (response) ->
      response.setEncoding "utf8"
      response.on "data", (data) ->
        try
          parsedData = JSON.parse data
        catch err
          parsedData = Error
        return next null, parsedData
    )

    request.on("error", (e) ->
      next JSON.parse e, null
    )

    request.write payload if payload isnt null
    request.end()
  return