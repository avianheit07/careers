module.exports = function (grunt) {
	grunt.registerTask('syncAssets', [
		'jade:dev',
		'sass:dev',
		'jst:dev',
		'sync:dev',
    'coffee:dev'
	]);
};
