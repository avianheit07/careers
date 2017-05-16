/**
 * Precompiles Underscore templates to a `.jst` file.
 *
 * ---------------------------------------------------------------
 *
 * (i.e. basically it takes HTML files and turns them into tiny little
 *  javascript functions that you pass data to and return HTML. This can
 *  speed up template rendering on the client, and reduce bandwidth usage.)
 *
 * For usage docs see:
 *    https://github.com/gruntjs/grunt-contrib-jst
 *
 */

module.exports = function(grunt) {

  var users = require('../pipeline').users,
    configLink ={
      dev:{
        options:{
          processName: function(filepath) {

            var name = filepath.replace(".tmp/public/templates/","");

            return name;
          }
        },
        files:{}
      }
    };

  for(var user in users){
    var jst_file = ".tmp/public/templates/jst_"+user+".js",
      dirs = users[user].templates;

    configLink.dev.files[jst_file] = dirs;
  }

  grunt.config.set('jst',configLink);

  grunt.loadNpmTasks('grunt-contrib-jst');
};
