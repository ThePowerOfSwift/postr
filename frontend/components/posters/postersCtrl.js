(function (){
    'use strict';
    var postr = angular.module('postr')

    postr.controller('postersCtrl', [
    '$scope',
    '$stateParams',
    'events',
    'posters'    
    function($scope, $stateParams, events, posters) {
        
        $scope.event = events.events[$stateParams.id];
        
        $scope.addPoster = function() {
            if(!$scope.title || $scope.title === '' ||
               !$scope.author || $scope.author === '' ||
               !$scope.description || $scope.description === '') { 
                return; 
            }
            
            $scope.event.posters.push({title: $scope.title, author: $scope.author,                      description: $scope.description, votes: 0});
            $scope.title = '';
            $scope.author = '';
            $scope.description = '';
        };
    
        $scope.incrementVotes = function(poster) {
            poster.votes++;
        }
        
        // Initializes collapsible behaviour
        $('.collapsible').collapsible({
            // Changes the collapsible behavior to expandable instead of the default accordion style
            accordion : false 
        });
    }]);
}());
