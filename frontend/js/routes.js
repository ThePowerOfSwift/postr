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
            controller: 'postersCtrl'
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
    
    

    return o;
}]);

