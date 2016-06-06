(function() {
    'use strict';
    module.exports = function(passport, passport_local, sqlite, crypto) {
        
        // Get sqlite3 database instance
        var db = new sqlite.Database('postr_database.db');
        var LocalStrategy = passport_local.Strategy;
        
        
        // Determines whether hash of given password is already stored
        function validPassword(password, storedHash) {
            var hash = crypto.pbkdf2Sync(password, this.salt, 1000, 128).toString('hex');

            return storedHash === hash;
        }
        
        passport.use(new LocalStrategy(
            function(username, password, done) {
                var getUsernameQuery
                    = "SELECT * \
                       FROM users \
                       WHERE username='" + username + "';";
                
                db.all(getUsernameQuery, function(err, users) {
                    if (err) {
                        console.log(err);
                        return done(err);
                    } else if (users.length == 0) {
                        // No stored usernames found
                        return done(null, false, { message: 'Incorrect username.' });
                    } else if (!validPassword(password, users[0].hash)) {
                        return done(null, false, { message: 'Incorrect password.' });
                    } else {
                        // Note that there should be just one user 
                        // database query output
                        return done(null, users[0]);
                    }
                });
            }
        ));    
    }
}());