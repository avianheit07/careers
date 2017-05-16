/**
 * Concatenate files.
 *
 * ---------------------------------------------------------------
 *
 * Concatenates files javascript and css from a defined array. Creates concatenated files in
 * .tmp/public/contact directory
 * [concat](https://github.com/gruntjs/grunt-contrib-concat)
 *
 * For usage docs see:
 * 		https://github.com/gruntjs/grunt-contrib-concat
 */
module.exports = function(grunt) {
    var users = require("../pipeline").users,
        linkConfig = {};

    for(var user in users){
        var js_key = "js_"+user,
            css_key = "css_"+user;
        obj = users[user]
        linkConfig[js_key] = {
            src: obj.js,
            dest:".tmp/public/concat/"+user+".js"
        };

        linkConfig[css_key] = {
            src: obj.css,
            dest:".tmp/public/concat/"+user+".css"
        };
        
    }
    
	grunt.config.set('concat',linkConfig);

	grunt.loadNpmTasks('grunt-contrib-concat');
};
