/**
 * Minify files with UglifyJS.
 *
 * ---------------------------------------------------------------
 *
 * Minifies client-side javascript `assets`.
 *
 * For usage docs see:
 * 		https://github.com/gruntjs/grunt-contrib-uglify
 *
 */
module.exports = function(grunt) {
    var users = require("../pipeline").users,
        linkConfig = {
            options:{
                mangle:false
            }
        };

    for(var user in users){
        var js_key = "js_"+user;

        linkConfig[js_key] = {
            src: [".tmp/public/concat/"+user+".js"],
            dest:".tmp/public/min/"+user+".min.js",

        };
        
    };
    
	grunt.config.set('uglify',linkConfig);

	grunt.loadNpmTasks('grunt-contrib-uglify');
};
