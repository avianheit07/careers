environment = process.env.NODE_ENV or 'development'
Host = 
  env: environment
  url: if environment is 'development' then 'http://localhost:1337' else 'http://careers.medspecialized.com'
module.exports = Host