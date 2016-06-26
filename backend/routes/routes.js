(function () {
    'use strict';
    module.exports = function(app, express, sqlite, multer, fs, gcloud,nn, node_geocoder,
                              geolib, crypto, jwt, express_jwt, passport) {

        // Get a router instance
        var router = express.Router();
        
        // Get sqlite3 database instance
        var db = new sqlite.Database('postr_database.db');
        
        // Get middleware for authentication jwt tokens
        var authToken = express_jwt({secret: process.env.TOKEN_SIGN});
        
        var upload = multer({ dest: 'uploads/'});
        
        // Allows loading of single file called 'file'
        // i.e. default dropzone filename
        var type = upload.single('file');
        
        // Threshold value used in poster recognition
        var thresholdValue = 0.15
        
        // GOOGLE_APPLICATION_CREDENTIALS and GCLOUD_PROJECT
        // environment variables should have already been set
        var projectId = process.env.GCLOUD_PROJECT;

        // Initialize gcloud
        gcloud = gcloud({
            projectId: 'foo'
        });

        // Obtain reference to the vision component
        var vision = gcloud.vision();
        
        // Set up for calls to Google Maps Service
        var options = {
            provider: 'google',
            httpAdapter: 'https', 
            apiKey: process.env.GOOGLE_MAPS_CREDENTIALS,
            formatter: null
        };

        // Obtain reference to the maps component
        var geocoder = node_geocoder(options);
        
        
        
        ///////////////////////////// Helper Functions /////////////////////////////
        
        // Extend nearest neighbour library to return the K most similar neighbours, 
        // rather than just the most nearest neighbour
        nn.findKMostSimilar = function(query, items, fields, callback) {
            var similarity, unmatchedFields, result, buffer, result, i, item, _ref
            buffer = []
            result = []
            i = 0
            var temp;

            // Calculate similarity for each given item
            while (i < items.length) {
              temp = {"title": items[i]["title"], "author": items[i]["author"]}
              item = temp
              _ref = nn.recordSimilarity(item, query, fields), similarity = _ref[0], unmatchedFields = _ref[1];
              buffer.push([similarity, items[i]])
              i++
            }

            // Sort in descending order of similarity
            buffer.sort(function(a, b) {
                a = a[0];
                b = b[0];

                return a < b ? 1 : (a > b ? -1 : 0);
            });
            
            // Return the 3 moster nearest neighbours
            result.push(buffer[0])
            result.push(buffer[1])
            result.push(buffer[2])

            callback(result, unmatchedFields)
        };

        // Constructs string representation of authors array
        // to be sent back to client-side
        function constructAuthorsString(posterAuthors) {
            posterAuthors = posterAuthors.split('\n');
            var numberAuthors = posterAuthors.length
            var limit = numberAuthors - 1;
            var authors = posterAuthors[0];
            
            for (var i = 1; i < limit; i++) {
                authors += ", " + posterAuthors[i];
            }
            
            if (numberAuthors != 1) {
                authors += " and " + posterAuthors[limit];    
            }
            
            return authors
        }
        
        // Uses the Vision API to detect labels in the given file.
        function detectText(inputFile, callback) {
            // Make a call to the Vision API to identify text
            vision.detectText(inputFile, { verbose: true }, function(err, text, apiResponse) {
                if (err) {
                    return callback(err);
                } else if (text == null) {
                    return res.status(500).json({
                        error: 'No text could be extracted'
                    });   
                } else {
                    // Remove image file from uploads directory
                    fs.unlinkSync(inputFile);
                    
                    // Apply nearest neighbour search to resulting text.
                    callback(null, text);       
                }
            });
        }
        
        // Performs nearest neighbour search
        function nearestNeighbourSearch(posterText, query, posterEntries, fields, res) { 
            nn.findKMostSimilar(query, posterEntries, fields, function(nearestNeighbors) {
                var highestSimilarity = nearestNeighbors[0][0]
                
                if (highestSimilarity < thresholdValue) {
                    return res.status(500).json({
                        msg: "Poster is not registered in this Event!"
                    })                        
                } else {
                    return res.status(200).json({
                        posters: nearestNeighbors
                    })    
                }
            });
        }
        
        // Correlates OCR output to poster entru in database
        function findNearestPosters(posterText, event_id, res) {
            // Nearest neighbour base of comparision. 
            var query = {title: posterText[0].desc, authors: posterText[0].desc };
            
            // fields variable used in nearest neighbour search
            var fields = [{ name: "title", measure: nn.comparisonMethods.word },
                          { name: "authors", measure: nn.comparisonMethods.word }];
            
            var getPostersForEventQuery = "SELECT poster_id, title, authors \
                                           FROM posters \
                                           WHERE event_id=" + event_id + ";"; 
            
            db.all(getPostersForEventQuery, function(err, rows) {
                if (err) {
                    console.log(err);
                    return res.status(500).json({
                        error: err
                    });
                }
                
                nearestNeighbourSearch(posterText[0].desc, query, rows, fields, res);
            });
        }

        // Returns Nearest events to a given latitude and longitue point 
        function findNearestEvents(userLat, userLon, events, res) {
            var eventLocations = [];
            var nearestEvents = [];
            var index;

            for (var i = 0; i < events.length; i++) {
                eventLocations.push({latitude: events[i]["latitude"], longitude: events[i]["longitude"]})
            }

            var nearestLocations = geolib.orderByDistance({latitude: userLat, longitude: userLon}, 
                                                 eventLocations)
            
            for (var i = 0; i < nearestLocations.length; i++) {
                index = nearestLocations[i]["key"]
                nearestEvents.push(events[index])
            }
            
            return res.status(200).json({
                events: nearestEvents
            })
        }

        
        ///////////////////////////// Routes /////////////////////////////
        
        // Return nearest events to mobile app user's current location. 
        app.post('/nearestEvents', authToken, function(req, res) {
            console.log('GET /nearestEvents');     
            
            // User's latitude and longitude points
            var userLat = req.body.latitude;
            var userLon = req.body.longitude;    
  
            // Database query
            var getEventsQuery
                = "SELECT * \
                   FROM events;";
            
            db.all(getEventsQuery, function(err, rows) {
                findNearestEvents(userLat, userLon, rows, res)
            });  
        });   
        
        // Applies optical character recogntion to identify 
        // corresponding poster entry in database
        app.post('/events/:event/findPoster', type, function(req, res) {    
            console.log('POST /events/:event/findPoster'); 
            
            var imageFilePath = req.file.path;
            var event_id = req.params.event;
            
            // Recognise text captured in poster image
            detectText(imageFilePath, function (err, posterText) {
                if (posterText == []) {
                    console.log("no text recognised")
                } else if (err) {
                    console.log(err);
                    return res.status(500).json({
                        error: err
                    });
                }

                console.log('\n\n\n' + 'OCR output:\n' + posterText[0].desc + '\n\n\n');
                
                findNearestPosters(posterText, event_id, res);
            });
        });
        
        // Return a list of events and associated metadata
        app.get('/events', authToken, function (req, res) {
            console.log('GET /events');
            
            // Database query
            var getEventsQuery
                = "SELECT * \
                   FROM events;";
            
            db.all(getEventsQuery, function(err, rows) {
                res.status(200).json({
                  events: rows
                });
            });
        });
        
        // Create a new event
        app.post('/events', authToken, function(req, res) {
            console.log('POST /events');
            
            // Convert event address into corresponding latitude and longitude point
            geocoder.geocode(req.body.address, function(err, mapRes) {
                
                // Event parameters
                var name = req.body.name;
                var description = req.body.description;
                var address = mapRes[0].formattedAddress;
                var latitude = mapRes[0].latitude;
                var longitude = mapRes[0].longitude;
                var start_date = req.body.start_date;
                var end_date = req.body.end_date;
                
                // Database query
                var postEventsQuery
                    = "INSERT INTO 'events' (name, address, latitude, longitude, start_date, end_date, description) \
                      VALUES ('" +  name + "', '" + address + "', " + latitude + ", " + longitude + ", '" +
                      start_date + "', '" + end_date + "', '" + description + "');";

                db.run(postEventsQuery, function(err) { 
                    if (err) {
                        console.log(err);
                        return res.status(500).json({
                           msg: err 
                        });
                    } else {
                        res.status(200).json({
                            event: {
                                event_id: this.lastID, 
                                name: name, 
                                address: address,
                                start_date: start_date, 
                                end_date: end_date,
                                description: description
                            }
                        });            
                    }

                })  
            });
        });
        
        
       // Returns posters associated with an individual event
        app.get('/events/:event', function (req, res) {
            console.log('GET /events/:event');
           
            // Event id used for database identification
            var event_id = req.params.event;
            
            // Database query
            var getPostersForEventQuery = "SELECT * \
                                           FROM posters \
                                           WHERE event_id=" + event_id + ";"; 
            
            db.all(getPostersForEventQuery, function(err, rows) {
                if (err) {
                    console.log(err);
                    return res.status(500).json({
                       msg: err 
                    });
                } else {
                    return res.status(200).json({
                        posters: rows
                    });                    
                }
            });
        });
        
        // Add a new poster to an event by ID
        app.post('/events/:event/posters', function (req, res) {
            console.log('POST /events/:event/posters');
            
            // Poster parameters
            var event_id = req.params.event;
            var title = req.body.title;
            var authors = constructAuthorsString(req.body.authors);
            var description = req.body.description;
            var votes = req.body.votes;
            
            // Database query
            var postPosterQuery
                = "INSERT INTO 'posters' (event_id, title, authors, description, votes) \
                   VALUES (" + event_id + ", '" + title + "', '" + authors + "', '" + 
                           description + "', " + votes + ");";
            
            db.run(postPosterQuery, function(err) { 
                if (err) {
                    console.log(err);
                    return res.status(500).json({
                       msg: err 
                    });
                } else {
                    return res.status(200).json({
                        poster: {
                            poster_id: this.lastID, 
                            event_id: event_id, 
                            title: title, 
                            authors: authors, 
                            description: description, 
                            votes: votes
                        }
                    });            
                }
            }); 
        });

        
        // Inserts poster_id and author in schema poster_authors schema
        // Later used to stop double voting
        function insertPosterAuthors(poster_id, author, res) {
            console.log("poster_id: " + poster_id + ", author: " + author)
            
            // Database query
            var addPosterAuthorQuery = "INSERT INTO 'poster_authors' (poster_id, author) \
                                        VALUES (" + poster_id + ", '" + author + "');"
                                        
            db.run(addPosterAuthorQuery, function(err) { 
                if (err) {
                    console.log(err);
                    return res.status(500).json({
                       msg: err 
                    });
                }
            });  
        }
        
        // Upvote a poster
        app.post('/events/:event/posters/:poster/upvote', authToken, function (req, res) {
            console.log('POST /events/:event/posters/:poster/upvote');
            
            // Poster, username parameters
            var username = req.body.username
            var event_id = req.params.event;
            var poster_id = req.params.poster;

            // Database queries    
            var addPosterVoterQuery = "INSERT INTO 'poster_voters' (poster_id, username) \
                                       VALUES (" + poster_id + ", '" + username + "');"
            var putUpvoteQuery = "UPDATE posters \
                                  SET votes = votes + 1 \
                                  WHERE event_id=" + event_id + 
                                " AND poster_id=" + poster_id + ";";

            
            // Check that user hasn't already voted for the poster
            db.run(addPosterVoterQuery, function(err) { 
                if (err) {
                    console.log(err)
                    return res.status(500).json({
                        msg: 'Already voted for this Poster!'
                    });
                } else {
                    // Upvote poster
                    db.run(putUpvoteQuery, function(err) {
                        if (err) {
                            console.log(err)
                            return res.status(500).json({
                                error: err
                            });
                        } else {
                            return res.status(200).json({
                                msg: 'Voted for Poster'
                            });
                        }
                    });                    
                }
            }); 
        });
        
        /////////////////////////////////////////////  Authentication Routes  ////////////////////////////////////////////////
        
        // Create JSON Web token used in
        // token-authentication
        function createJWT(username) {  
          return jwt.sign({
              usename: username,
          }, process.env.TOKEN_SIGN, {
              expiresIn : 5*60*60*24
          });
        }
        
        app.post('/register', function(req, res) {
            console.log('POST /register')
            
            var username = req.body.username;
            var password = req.body.password;
            
            // Check to see if username and password fields have
            // been filled out
            if(!username || !password) {
                return res.status(500).json({
                    message: 'Please fill username and password fields'
                });
            } 
            
            // Create salt and a hash of password 
            // to be stored in users schema
            var salt = crypto.randomBytes(32).toString('hex');
            var hash = crypto.pbkdf2Sync(password, salt, 1000, 128, 'sha512').toString('hex');
            
            // Database query
            var postUserQuery
                = "INSERT INTO 'users' (username, hash, salt) \
                   VALUES ('" + username + "', '" + hash + "', '" +
                    salt + "');";
            
            db.run(postUserQuery, function(err) { 
                if (err) {
                    console.log(err);
                }       
                
                // Generate and return JSON Web Token 
                return res.status(200).json({
                    token: createJWT(username), 
                    username: username
                }); 
            });
        });
        
        app.post('/login', function(req, res){
            console.log('POST /login')
            
            var username = req.body.username;
            var password = req.body.password;

            if (!req.body.username || !req.body.password){
                return res.status(500).json({
                    msg: 'Please fill username and password fields'
                });
            }

            passport.authenticate('local', function(err, user, errorMsg){
                if (err) {
                    console.log(err);
                    return res.status(500)
                } else if(user){
                    // Parse out username
                    // Generate and return JSON Web Token 
                    return res.status(200).json({
                        token: createJWT(username), 
                        username: username
                    }); 
                } else {
                    return res.status(500).json({
                        error: errorMsg
                    });
                }
            })(req, res);
        });
        
        
        // Use the router we defined with the prefix of /api/
        app.use('/api', router);   
    }
}());
