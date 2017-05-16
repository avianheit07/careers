module.exports = function (grunt) {
  var tasks = [
    'compileAssets',
    'concat',
    'uglify',
    'cssmin'
  ];


  var users = require("../pipeline").users;

  for(var user in users){
    var names = {
      prodJs:"prodJs_"+user,
      prodStyles:"prodStyles_"+user,
      devTpl:"devTpl_"+user
    }
    for(var key in names){
      tasks.push("sails-linker:"+names[key]);
    }
  };


  grunt.registerTask('buildProd', tasks);
};
