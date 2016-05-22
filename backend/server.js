(function () {
    'use strict';
    
    // modules =================================================
    var express        = require('express');
    var app            = express();
    var bodyParser     = require('body-parser');
    var methodOverride = require('method-override');
    var favicon        = require('serve-favicon');
    var logger         = require('morgan');
    var mongoose = require('mongoose');
    var server;
    
    
    // configuration ===========================================
        
    // config files
    var db = require('./config/db');

    // set our port
    var port = process.env.PORT || 8080; 

    // connect to our mongoDB database 
    // (uncomment after you enter in your own credentials in config/db.js)
    // mongoose.connect(db.url); 

    
    // get all data/stuff of the body (POST) parameters
    // parse application/json 
    app.use(bodyParser.json()); 

    // parse application/x-www-form-urlencoded
    app.use(bodyParser.urlencoded({ extended: true })); 

    // parse application/vnd.api+json as json
    app.use(bodyParser.json({ type: 'application/vnd.api+json' })); 
    
    // override with the X-HTTP-Method-Override header in the request. simulate DELETE/PUT
    app.use(methodOverride('X-HTTP-Method-Override')); 

    // Set the static files location
    app.use(express.static(__dirname + '/../frontend')); 


    // routes ==================================================
    
    require('./routes/routes.js')(app, express); 

   
    // start app ===============================================
    // startup our app at http://localhost:8080
    app.listen(port, function () {
        console.log("Postr app listening at http://localhost:8080/");
        console.log('Port ' + port);    
    });  

    // expose app           
    exports = module.exports = app;                         
}());