(function (){
    'use strict';
    var postr = angular.module('postr')

    postr.controller('eventsCtrl', [
    '$scope',
    '$http',
    '$stateParams',
    'events',
    function($scope, $http, $stateParams, events) {
        console.log(events.events[$stateParams.id]);
        $scope.events = events.events;
    
        $scope.addEvent = function() {
            if(!$scope.name || $scope.name === '' ||
               !$scope.description || $scope.description === '') { 
                return; 
            }

            $scope.events.push({name: $scope.name, description: $scope.description, date: 0, posters: []});
            $scope.name = '';
            $scope.description = '';
        };
        
        // Initializes collapsible behaviour
        $('.collapsible').collapsible({
            // Changes the collapsible behavior to expandable instead of the default accordion style
            accordion : false 
        });
    }]);
}());
