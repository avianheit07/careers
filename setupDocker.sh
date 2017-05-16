docker run -p 8000:27017 --name career_mongo -v `pwd`/data:/data/db -d dockerfile/mongodb
docker run --name career_redis -d redis
docker run -itd -p 1337:1337 -e VIRTUAL_HOST=careers.medspecialized.com,careers.meditab.com --name career_app --link career_mongo:mongo --link career_redis:redis -v `pwd`:/src getneil/sails-prod