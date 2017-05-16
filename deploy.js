var express = require('express');
var bodyParser = require("body-parser");
var app = express();
var exec = require('child_process').exec; 

app.use(bodyParser.urlencoded({extended:false}));
app.use(bodyParser.json());

app.get("/",function(req,res){
  res.json({online:true});
});

app.post("/production",function(req,res){
  console.log('Hook successful');
  exec('./production.sh',function(err,stdout,stderr){
    if(err){
      console.log('Error in shell script');
      res.json({error:err});
    }else{
      console.log('Successfully executed shell script');
      res.json({deployed:true});
    }
  });
});

app.listen(9005);

console.log("Auto-Deploy App listening at 9005");