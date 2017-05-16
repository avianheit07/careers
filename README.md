# Angular Modular Setup and Sails.js

Requirements:

+ Node.js

this assumes you have installed node.js already

open command line:

	npm install -g sails

	npm install -g grunt

go inside the project folder:

	npm install

	sails lift

for production version:
	
	sails lift --prod

## Take note

the public folder, as a role, in the modules folder is not directly related to the .tmp/public folder. It's just that by default Sails.js creates a public folder inside the .tmp folder.
