var passport = require('passport')
  , Google   = require('passport-google-oauth').OAuth2Strategy
  , Host     = require('../api/services/Host')
  , config = Host.env === 'development' ? require('./env/development').passport : require('./env/production').passport;

var verifyHandler = function (token, tokenSecret, profile, done) {
  process.nextTick(function () {
    var oauth = profile._json;
    data = {
      email: oauth.email,
      strategy: 'oauth'
    }
    Api('POST', '/user/authenticate', data, function (err, result) {
      if (result.appuser != undefined) {
        return done(null, result)
      } else {
        error = {
          statusCode: 400,
          error: 'Unauthorized',
          message: 'Invalid Email Address'
        }
        return done(error);
      }
    });
  });
};

passport.serializeUser(function (user, done) {
  done(null, user);
});

passport.deserializeUser(function (user, done) {
  done(null, user);
  // User.findOne({id: id}, function (err, user) {
  //   done(err, user);
  // });
});

module.exports.http = {
  customMiddleware: function (app) {
    passport.use(new Google({
      clientID      : config.clientID,
      clientSecret  : config.clientSecret,
      callbackURL   : config.callbackURL
    }, verifyHandler));

    app.use(passport.initialize());
    app.use(passport.session());
  }
};