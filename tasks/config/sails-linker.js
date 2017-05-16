/**
 * Autoinsert script tags (or other filebased tags) in an html file.
 *
 * ---------------------------------------------------------------
 *
 * Automatically inject <script> tags for javascript files and <link> tags
 * for css files.  Also automatically links an output file containing precompiled
 * templates using a <script> tag.
 *
 * For usage docs see:
 * 		https://github.com/Zolmeister/grunt-sails-linker
 *
 */
module.exports = function(grunt) {
	var users = require("../pipeline").users,
		linkerConfig = {};


	for(var user in users){
		var names = {
			devJs:"devJs_"+user,
			prodJs:"prodJs_"+user,
			devStyles:"devStyles_"+user,
			prodStyles:"prodStyles_"+user,
			devTpl:"devTpl_"+user
		}
		var U = users[user];

		for(var key in names){
			var options = {
				script:{
					startTag: '// SCRIPTS',
					endTag: '// SCRIPTS END',
					fileTmpl: 'script(src="%s")',
					appRoot: '.tmp/public'
				},
				style:{
					startTag: '// STYLES',
					endTag: '// STYLES END',
					fileTmpl: 'link(rel="stylesheet", href="%s")',
					appRoot: '.tmp/public'
				},
				template:{
					startTag: '// TEMPLATES',
					endTag: '// TEMPLATES END',
					fileTmpl: 'script(type="text/javascript", src="%s")',
					appRoot: '.tmp/public'
				}			
			}
			/*
				
			*/
			var prop = names[key],
				isRelative = prop.indexOf("Relative") > -1,
				keyConfig = {
					options:{},
					files:{}
				},
				files_dir = "views/"+user+".jade",
				link_dir = [];

			if( prop.indexOf("Js") !== -1 ){
				delete options.script.relative;

				keyConfig.options = options.script
				
				if(prop.indexOf("dev") !== -1){
					link_dir = U.js;
				}else{
					link_dir = [];
					link_dir.push(".tmp/public/min/"+user+".min.js");
				}

			}else if( prop.indexOf("Styles") !== -1 ){
				delete options.style.relative;
				
				keyConfig.options = options.style;

				if(prop.indexOf("dev") !== -1){
					link_dir = U.css;
				}else{
					link_dir = [];
					link_dir.push(".tmp/public/min/"+user+".min.css");
				}
			}else{
				keyConfig.options = options.template;
				link_dir = [];
				link_dir.push(".tmp/public/templates/jst_"+user+".js");
				//templates 'views/**/*.jade': ['.tmp/public/jst.js']
			}


			keyConfig.files[files_dir] = link_dir;

			linkerConfig[prop] = keyConfig;
		}
		
	}

	grunt.config.set('sails-linker',linkerConfig);

	grunt.loadNpmTasks('grunt-sails-linker');
};
