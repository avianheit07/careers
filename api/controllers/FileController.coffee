fs = require 'fs'
module.exports = 
  upload: (req, res) ->
    dir      = __dirname + '/../../.tmp/resume'

    fs.mkdirSync(dir) if !fs.existsSync(dir)

    req.file('file').upload({dirname: dir}
      , (err, file) ->
        if err
          return res.serverError err

        res.json file
    )

  download: (req, res) ->
    id = req.param 'id'
    Resume.findOne(id).exec (err, result) ->
      return res.serverError err if err
      dir = __dirname + "/../../.tmp/resume/#{result.name}.#{result.extension}"
      res.attachment(dir)
      file = fs.createReadStream dir    
      file.on 'error', (error) ->
        res.notFound()
      file.on 'readable', ->
        file.pipe(res)
