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
                    return events.getAll();
                }]
            }
        })
        .state('posters', {
            url: '/posters/{id}', 
            templateUrl: 'components/posters/posters.html', 
            controller: 'postersCtrl', 
            resolve: {
                posters: ['$stateParams', 'events', function($stateParams, events) {
                    return events.get($stateParams.id); 
                }]
            }
        });
    
    $urlRouterProvider.otherwise('/home');
});

postr.factory('events', ['$http', function($http) {
    var o = {
        events: []
    };
    
    o.getAll = function() {
        return $http.get('/events').success(function(response) {
            angular.copy(response.events, o.events);
        });
    };
    
    o.create = function(event) {
        return $http.post('/events', event).then(function(response) {
                o.events.push(response.data.event);                
        });   
    }
    
    // Return posters for a given event
    o.get = function(event_id) {
        return $http.get('/events/' + event_id).then(function(response){
            return response.data.posters;
        });       
    };

    // Add a poster for a given event
    o.addPoster = function(event_id, poster, posters) {
        return $http.post('/events/' + event_id + '/posters', poster).then(function(response) {
            posters.push(response.data.poster);
        });
    };
    
    o.vote = function(poster) {
        return $http.put('/events/' + poster.event_id + '/posters/' + poster.poster_id + '/upvote').success(function(response) {
            poster.votes++;
        });
    };
    
    return o;
}]);

