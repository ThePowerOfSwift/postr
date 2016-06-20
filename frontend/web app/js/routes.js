var postr = angular.module('postr');

postr.config(function($stateProvider, $urlRouterProvider) {
    $stateProvider
        .state('home', {
          url: '/home',
          templateUrl: 'components/home/home.html',
          controller: 'homeCtrl'
        })
        .state('events', {
            url: '/events', 
            templateUrl: 'components/events/events.html', 
            controller: 'eventsCtrl',
            resolve: {
                eventPromise: ['events', function(events){
                    return events.getAllEvents();
                }]
            }
        })
        .state('posters', {
            url: '/posters/{id}', 
            templateUrl: 'components/posters/posters.html', 
            controller: 'postersCtrl', 
            resolve: {
                posters: ['$stateParams', 'events', function($stateParams, events) {
                    return events.getPosters($stateParams.id); 
                }]
            }
        });
    
    $urlRouterProvider.otherwise('/home');
});

// Factory for producing authentication methods
postr.factory('authToken', ['$http', '$window', function($http, $window){
    var authToken = {};
    var username;
    
    // Log Postr user in and store JWT from server 
    // for later authentication
    authToken.loginToAccount = function(postrUser) {
        return $http.post('/login', postrUser).success(function(res){
            authToken.storeToken(res.token);
        });
    }
    
    // Logout from account
    authToken.logoutFromAccount = function() {
        $window.localStorage.removeItem('postr_token');
    };
    
    // Get current user's username
    authToken.getUser = function() {
        return username
    }
    
    // Register Postr user and store JWT from server 
    // for later authentication
    authToken.registerAccount = function(user){
        return $http.post('/register', user).success(function(res){
            authToken.storeToken(res.token);
        });
    };
    
    // Store JWT for later authentication
    authToken.storeToken = function(postr_token) {
        $window.localStorage['postr_token'] = postr_token;
    };
    
    authToken.retrieveToken = function() {
        return $window.localStorage['postr_token'];
    };
    
    // Check to see if Postr user is logged in
    authToken.isLoggedIn = function() {
        // Get stored JSON web token
        var JWT = authToken.retrieveToken()

        if(JWT){
            var parsedJWT = JWT.split('.')[1]
            console.log($window.atob(parsedJWT))
            var jwtPayload = JSON.parse($window.atob(parsedJWT));
            username = jwtPayload.username
            console.log(jwtPayload)
            console.log(Date.now())
            
            return true;   
//            return payload.exp > Date.now() / xxx;
        } else {
            return false;
        }
    };

    return authToken;
}])

postr.factory('events', ['$http', 'authToken', function($http, authToken) {
    var manager = {
        events: []
    };
    
    // Submits http request to get all events 
    manager.getAllEvents = function() {
        return $http.get('/events', {headers: {Authorization: 'Bearer ' + authToken.retrieveToken()}
          }).success(function(response) {
            angular.copy(response.events, manager.events);
        });
    };
    
    // Create an event 
    manager.create = function(event) {
        return $http.post('/events', event, {headers: {Authorization: 'Bearer ' + authToken.retrieveToken()}
          }).then(function(response) {
            manager.events.push(response.data.event);                
        });   
    }
    
    // Return posters for a given event
    manager.getPosters = function(event_id) {
        return $http.get('/events/' + event_id, {headers: {Authorization: 'Bearer ' + authToken.retrieveToken()}
          }).then(function(response){
            return response.data.posters;
        });       
    };

    // Add a poster for a given event
    manager.addPoster = function(event_id, poster, posters) {
        return $http.post('/events/' + event_id + '/posters', poster, {headers: {Authorization: 'Bearer ' + authToken.retrieveToken()}
          }).then(function(response) {
            console.log(response)
            posters.push(response.data.poster);
        });
    };
    
    // Vote for a given poster
    manager.vote = function(poster) {
        return $http.put('/events/' + poster.event_id + '/posters/' + poster.poster_id + '/upvote', {headers: {Authorization: 'Bearer ' + authToken.retrieveToken()}
          }).success(function(response) {
            poster.votes++;
        });
    };
    
    return manager;
}]);
