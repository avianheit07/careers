/**
 * Development environment settings
 *
 * This file can include shared settings for a development team,
 * such as API keys or remote database passwords.  If you're using
 * a version control solution for your Sails app, this file will
 * be committed to your repository unless you add it to your .gitignore
 * file.  If your repository will be publicly viewable, don't add
 * any private information to this file!
 *
 */

module.exports = {

  /***************************************************************************
   * Set the default database connection for models in the development       *
   * environment (see config/connections.js and config/models.js )           *
   ***************************************************************************/

  // models: {
  //   connection: 'someMongodbServer'
  // }
  
  passport: {
    clientID      : '122616430859-6odef9j2fs2g2t3plilacd2s058tnodb.apps.googleusercontent.com',
    clientSecret  : 'kRKVy9LeLzgArm3OfCPJRlgo',
    callbackURL   : 'http://localhost:1337/auth/google'
  }

};
