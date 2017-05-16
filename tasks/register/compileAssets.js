module.exports = function (grunt) {
	grunt.registerTask('compileAssets', [
		'clean:dev',
		'jade:dev',
		'copy:dev',
		'jst:dev',
		'sass:dev',
    'coffee:dev'
	]);
};
