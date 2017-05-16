pm2 stop Careers
git checkout -- .
git pull origin master
sails www --prod
pm2 start app.js --name Careers -- --prod