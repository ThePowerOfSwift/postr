(function () {
    'use strict';
    
    // modules
    var express        = require('express');
    var bodyParser     = require('body-parser');
    var passport       = require('passport');
    var passport_local = require('passport-local');
    var crypto         = require('crypto');
    var jwt            = require('jsonwebtoken');
    var express_jwt    = require('express-jwt');
    var sqlite         = require('sqlite3');
    var multer         = require('multer')
    var fs             = require('fs');
    var gcloud         = require('gcloud');
    var nn             = require('nearest-neighbor');
    var node_geocoder  = require('node-geocoder');
    var geolib         = require('geolib')
    var app            = express();

        
    // set our port
    var port = process.env.PORT || 3000; 
        
    // Passport configuration
    require('./config/passport.js')(passport, passport_local, sqlite, crypto);
    
    // get all data/stuff of the body (POST) parameters
    // parse application/json 
    app.use(bodyParser.json()); 

    // parse application/x-www-form-urlencoded
    app.use(bodyParser.urlencoded({ extended: true })); 
    
    // Set the static files location
    app.use(express.static(__dirname + '/../frontend/web app')); 
    
    // routes 
    require('./routes/routes.js')(app, express, sqlite, multer, fs, gcloud, nn, node_geocoder, 
                                  geolib, crypto, jwt, express_jwt, passport); 
    
    // Passport initilisation
    app.use(passport.initialize());
    
    // expose app           
    exports = module.exports = app; 
   
    // Startup our app at http://localhost:3000
    app.listen(port, function () {
        console.log("Postr app listening at http://localhost:3000/");
        console.log('Port ' + port);    
    });  
                            
}());