/**
 * Compile CoffeeScript files to JavaScript.
 *
 * ---------------------------------------------------------------
 *
 * Compiles coffeeScript files from `assest/modules` into Javascript and places them into
 * `.tmp/public/js` directory.
 */
module.exports = function(grunt) {

  grunt.config.set('coffee', {
    dev: {
      options: {
        bare: true,
        sourceMap: true,
        sourceRoot: './'
      },
      files: [{
        expand: true,
        cwd: 'assets/modules/',
        src: ['**/*.coffee'],
        dest: '.tmp/public/js/',
        ext: '.js'
      },{
        expand: true,
        cwd: 'assets/js/',
        src: ['**/*.coffee'],
        dest: '.tmp/public/js/',
        ext: '.js'
      }]
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
};
