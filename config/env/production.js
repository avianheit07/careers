/**
 * Production environment settings
 *
 * This file can include shared settings for a production environment,
 * such as API keys or remote database passwords.  If you're using
 * a version control solution for your Sails app, this file will
 * be committed to your repository unless you add it to your .gitignore
 * file.  If your repository will be publicly viewable, don't add
 * any private information to this file!
 *
 */

module.exports = {

  /***************************************************************************
   * Set the default database connection for models in the production        *
   * environment (see config/connections.js and config/models.js )           *
   ***************************************************************************/

  models: {
    connection: 'mongo'
  },

  /***************************************************************************
   * Set the port in the production environment to 80                        *
   ***************************************************************************/

  port: 1337,

  /***************************************************************************
   * Set the log level in production environment to "silent"                 *
   ***************************************************************************/

  // log: {
  //   level: "silent"
  // }

  connections: {
    mongo: {
      adapter: 'sails-mongo',
      host: process.env.MONGO_PORT_27017_TCP_ADDR || 'localhost',
      port: process.env.MONGO_PORT_27017_TCP_PORT || 27017,
      user: '',
      password: '',
      database: 'careers'
    }
  },

  passport: {
    clientID      : '962295795738-oep4c7b56hmv9ascfv514bj6l0k63por.apps.googleusercontent.com',
    clientSecret  : 'mAUjJ-BYrgffsLmKmqqNyrVC',
    callbackURL   : 'http://careers.medspecialized.com/auth/google'
  }

};
