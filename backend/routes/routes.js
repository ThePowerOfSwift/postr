(function () {
    'use strict';
    module.exports = function(app, express) {
        // Get a router instance
        var router = express.Router();
        
        // server routes ======================================
        // Handles API calls, authentication routes, etc
        
        router.get('/', function (req, res) {
            res.status(200).json({
              message: 'postr API running',
              data: 'Test Data'
            });
        });
        
        // Route for creating goes here (app.post)
        // Route for deleting goes here (app.delete)
        
        // frontend routes ======================================    
    
        // Catch any routes not found
        router.use(function (req, res) {
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