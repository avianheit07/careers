/**
 * Compress CSS files.
 *
 * ---------------------------------------------------------------
 *
 * Minifies css files and places them into .tmp/public/min directory.
 *
 * For usage docs see:
 * 		https://github.com/gruntjs/grunt-contrib-cssmin
 */
module.exports = function(grunt) {
    var users = require("../pipeline").users,
    	linkConfig = {};

    for(var user in users){
    	var css_key = "css_"+user;
        
    	linkConfig[css_key] = {
    		src: [".tmp/public/concat/"+user+".css"],
    		dest:".tmp/public/min/"+user+".min.css"
    	};
    	
    };

	grunt.config.set('cssmin',linkConfig);

	grunt.loadNpmTasks('grunt-contrib-cssmin');
};
