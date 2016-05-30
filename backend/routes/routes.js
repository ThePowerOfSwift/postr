(function () {
    'use strict';
    module.exports = function(app, express, sqlite, multer, 
                              fs, gcloud, nn, crypto) {
        
        // Get a router instance
        var router = express.Router();
        
        // Get sqlite3 database instance
        var db = new sqlite.Database('postr_database.db');
        
        
        var upload = multer({ dest: 'uploads/'});
        
        // Allows loading of single file called 'file'
        // i.e. default dropzone filename
        var type = upload.single('file');
        
        
        // GOOGLE_APPLICATION_CREDENTIALS and GCLOUD_PROJECT
        // environment variables should have already been set
        var projectId = process.env.GCLOUD_PROJECT;

        // Initialize gcloud
        gcloud = gcloud({
          projectId: projectId
        });

        // Obtain reference to the vision component
        var vision = gcloud.vision();
        
        
        ///////////////////////////// Helper Functions /////////////////////////////
        
        // Generates json web token
        function generateJWT(username, user_id) {
            // startDay = current day
            // Token will expire in 50 days
            var startDay = Date();
            var exp = new Date(startDay);
            exp.setDate(startDay.getDate() + 50);
        
            
            // TODO: instead of hardcoding secret to be used
            // to sign web tokens, store it in an environment variable
            return jwt.sign({
                user_id: user_id, 
                username: username, 
                exp: parseInt(exp.getTime() / 1000)
            }, 'SECRET');
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
        
        function upvoteMatchedPoster(title, author, res) {
            console.log('title: ' + title);
            console.log('author: ' + author);
            
            var putUpvoteQuery 
                = "UPDATE posters \
                   SET votes = votes + 1 \
                   WHERE title='" + title + "'\
                   AND author='" + author + "';";
            
            var getPosterQuery
                = "SELECT * \
                   FROM posters \
                   WHERE title='" + title + "'\
                   AND author='" + author + "';";

            // Return poster that has been upvoted
            db.all(getPosterQuery, function(err, rows) {
                if (err) {
                    console.log(err);
                    return res.status(500).json({
                        error: err
                    });
                }

                // rows array should have just one element
                return res.status(200).json({
                    poster_id: rows[0].poster_id,
                    title: rows[0].title, 
                    author: rows[0].author 
                });  
            });
        }
        
        function nearestNeighbourSearch(query, posterEntries, fields, res) { 
            nn.findMostSimilar(query, posterEntries, fields, function(nearestNeighbor, probability) {
                var matchedPoster = nearestNeighbor;
                var probSuccess = probability;

                console.log('matchedPoster title: ' + matchedPoster.title 
                + ', author: ' + matchedPoster.author);
                console.log('Probability of success: '+ probSuccess + '\n');

                // Some arbitratry threshold for now
                if (probSuccess < 0.01) {
                    var msg = 'Did not match any known poster entries!';
                    console.log(msg);

                    return res.status(500).json({
                        error: msg
                    });   
                } else {
                    upvoteMatchedPoster(matchedPoster.title, matchedPoster.author, res);
                }   
            });
        }
        
        function findNearestNeighbour(posterText, event_id, res) {
            // Nearest neighbour base of comparision. 
            var query = { name: posterText[0].desc, author: posterText[0].desc };
            
            // fields variable used in nearest neighbour search
            var fields = [{ name: "title", measure: nn.comparisonMethods.word },
                          { name: "author", measure: nn.comparisonMethods.word }];
            var getPostersForEventQuery = "SELECT title, author \
                                           FROM posters \
                                           WHERE event_id=" + event_id + ";"; 
            
            db.all(getPostersForEventQuery, function(err, rows) {
                if (err) {
                    console.log(err);
                    return res.status(500).json({
                        error: err
                    });
                }
                
                nearestNeighbourSearch(query, rows, fields, res);
            });
        }
        
        
        
        ///////////////////////////// Routes /////////////////////////////
   
        app.post('/events/:event/websiteUpload', type, function(req, res) {
            console.log('POST /events/:event/websiteUpload'); 
            
            var imageFilePath = req.file.path;
            var event_id = req.params.event;
            
            detectText(imageFilePath, function (err, posterText) {
                if (err) {
                    console.log(err);
                    return res.status(500).json({
                        error: err
                    });
                }

                console.log('\n' + 'OCR output:\n' + posterText[0].desc + '\n');
                
                findNearestNeighbour(posterText, event_id, res);
            });
        });
        
        
        // Return a list of events and associated metadata
        app.get('/events', function (req, res) {
            console.log('GET /events');
            
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
        app.post('/events', function(req, res) {
            console.log('POST /events');
            
            var name = req.body.name;
            var description = req.body.description;
            var start_date = req.body.start_date;
            var end_date = req.body.end_date;
            
            var postEventsQuery
                = "INSERT INTO 'events' (name, description, start_date, end_date) \
                  VALUES ('" +  name + "', '" + description + "', '" + start_date + "', '" + end_date + "');";
            
            db.run(postEventsQuery, function(err) { 
                if (err) {
                    console.log(err);
                }
                
                return res.status(200).json({
                    event: {
                        event_id: this.lastID, 
                        name: name, 
                        description: description, 
                        start_date: start_date, 
                        end_date: end_date
                    }
                });            
            }) 
        });
        
       // Returns posters associated with an individual event
       app.get('/events/:event', function (req, res) {
            console.log('GET /events/:event');
           
            var event_id = req.params.event;
            
            var getPostersForEventQuery = "SELECT * \
                                           FROM posters \
                                           WHERE event_id=" + event_id + ";"; 
            
            db.all(getPostersForEventQuery, function(err, rows) {
                if (err) {
                    console.log(err);
                }
                
                return res.status(200).json({
                    posters: rows
                });
            });
        });
        
        // Add a new poster to an event by ID
        app.post('/events/:event/posters', function (req, res) {
            console.log('POST /events/:event/posters');
            
            var event_id = req.params.event;
            var title = req.body.title;
            var author = req.body.author;
            var description = req.body.description;
            var votes = req.body.votes;
            
            var postPosterQuery
                = "INSERT INTO 'posters' (event_id, title, author, description, votes) \
                   VALUES (" + event_id + ", '" + title + "', '" + author + "', '" + 
                           description + "', " + votes + ");";
            
            db.run(postPosterQuery, function(err) { 
                if (err) {
                    console.log(err);
                }
                
                return res.status(200).json({
                    poster: {
                        poster_id: this.lastID, 
                        event_id: event_id, 
                        title: title, 
                        author: author, 
                        description: description, 
                        votes: votes
                    }
                });            
            }); 
        });
        
        // Upvote a poster
        app.put('/events/:event/posters/:poster/upvote', function (req, res) {
            console.log('PUT /events/:event/posters/:poster/upvote');
            
            var event_id = req.params.event;
            var poster_id = req.params.poster;
            
            var putUpvoteQuery 
                = "UPDATE posters \
                   SET votes = votes + 1 \
                   WHERE event_id=" + event_id + 
                   " AND poster_id=" + poster_id + ";";
            
            var getPosterQuery = "SELECT * \
                                  FROM posters \
                                  WHERE poster_id=" + poster_id + ";"; 
            
            db.run(putUpvoteQuery, function(err) {
                if (err) {
                    console.log(err);
                }
            });
            
            // Return poster that has been upvoted
            db.all(getPosterQuery, function(err, posters) {
                if (err) {
                    console.log(err);
                }
                
                // Note should just be one element  
                // in response array.
                return res.status(200).json({
                    posters: posters
                });  
            });
        });
        
        
        app.post('/register', function(req, res) {
            var username = req.body.username;
            var password = req.body.password;
            
            if(!username || !password) {
                return res.status(500).json({
                    message: 'Please fill out all fields'
                });
            } else if (false) {
                // TODO: account for case when a given 
                // username already exists in schema    
            }
            
            // Create salt and a hash of password to be stored
            // in users schema
            var salt = crypto.randomBytes(32).toString('hex');
            var hash = crypto.pbkdf2Sync(password, salt, 1000, 128).toString('hex');
            
            var postUserQuery
                = "INSERT INTO 'users' (username, hash, salt) \
                   VALUES ('" + username + "', '" + 
                   hash + "', '" + salt + "');";
            
            db.run(postUserQuery, function(err) { 
                if (err) {
                    console.log(err);
                }       
                
                return res.status(200).json({
                    token: generateJWT(username, this.lastID)
                }); 
            });
        });
        
        // Use the router we defined with the prefix of /api/
        app.use('/api', router);   
    }
}());