module.exports = function (grunt) {
	var tasks = [],users = require("../pipeline").users;

	for(var user in users){
		var names = {
			devJs:"devJs_"+user,
			devStyles:"devStyles_"+user,
			devTpl:"devTpl_"+user
		}
		
		for(var key in names){
			tasks.push("sails-linker:"+names[key]);
		}
	}

	grunt.registerTask('linkAssets',tasks);
};
