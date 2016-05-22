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
            controller: 'eventsCtrl'
        })
        .state('posters', {
            url: '/posters/{id}', 
            templateUrl: 'components/posters/posters.html', 
            controller: 'postersCtrl'
        });
    
    $urlRouterProvider.otherwise('/home');
});

postr.factory('events', [function() {
    var o = {
        events: [
            { name: 'IC Maths First Year Poster Competition',     description: 'Lorem ipsum dolor sit amet.', 
              date: 5,
              posters: [
                { title: 'Web Security: Man in the Middle Attack',     author: 'Steven Kingaby', 
                  description: 'Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.',
                  votes: 7}
                ]
            },
            { name: 'Nuclear Physics Conference', 
              description: 'Lorem ipsum dolor sit amet.', 
              date: 2, 
              posters: [
                { title: 'Machine Learning: Decision Trees',     author: 'Steven Kingaby', 
                  description: 'Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet.',
                  votes: 10}
                ]
            }
        ]
    };

    return o;
}]);

