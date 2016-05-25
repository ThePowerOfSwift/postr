(function () {
    'use strict';
    module.exports = function(app, express, sqlite) {
        
        
        // Get a router instance
        var router = express.Router();
        
        var db = new sqlite.Database('postr_database.db');
        
        // server routes ======================================
        // Handles API calls, authentication routes, etc
        
        // Return a list of events and associated metadata
        app.get('/events', function (req, res) {
            console.log('GET /events');
            
            var getEventsQuery = "SELECT * \
                                  FROM events";
            
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
                
                res.status(200).json({
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
        
        
        
       // Return an individual event with associated posters
       app.get('/events:id', function (req, res) {
            console.log('GET /events:id');
           
            res.status(200).json({
              message: 'GET /events:id',
              data: 'Test Data'
            });
        });
        
        // Add a new poster to an event by ID
        app.post('/events/:id/posters', function (req, res) {
            console.log('POST /events:id/posters');
            
            res.status(200).json({
              message: 'POST /events/:id/posters',
              data: 'Test Data'
            });
        });
        
        // Upvote a poster
        app.put('/events/:id/posters/:id/upvote', function (req, res) {
            console.log('PUT events/:id/posters/:id/upvote');
            
            res.status(200).json({
              message: 'PUT /events/:id/posters/:id/upvote',
              data: 'Test Data'
            });
        });
//        
        
        // frontend routes ======================================    
    
        // TODO: Does this do anything?     
        // Catch any routes not found
        app.use(function (req, res) {
            res.status(500).json(
                {
                error: 'Route not found'
                }
            );
        });
        
        // Use the router we defined with the prefix of /api/
        app.use('/api', router);
        
    }
}());