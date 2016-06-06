(function (){
    'use strict';
    var postr = angular.module('postr');
    
    postr.controller('eventsCtrl', [
    '$scope',
    '$http',
    '$stateParams',
    'events',
    function($scope, $http, $stateParams, events) {
        $scope.events = events.events;
        
        $scope.addEvent = function() {             
            if(!$scope.name || $scope.name === '' ||
               !$scope.start_date || !$scope.end_date ||
               compareDates($scope.start_date) < getToday() ||
               compareDates($scope.start_date) > compareDates($scope.end_date)) { 
                console.log('Error in eventsCtrl. TODO: write an error handler');
                return; 
            }

            events.create({name: $scope.name, description: $scope.description, 
                           start_date: $scope.start_date, end_date: $scope.end_date});
            $scope.name = '';
            $scope.start_date = '';
            $scope.end_date = '';
            $scope.description = '';
        };
        
        // Get an integer representation of today's date
        // To be used for comparision later. 
        var getToday = function() {
            // Note that january month is equivalent to 0,
            // so we increment the mm month variable.
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1; 
            var yyyy = today.getFullYear();

            return dd + mm * 30 + yyyy * 365;
        }
        
        // Adds up the total number of dates since 0 A.D.
        // Comparison function to be used as a filter in ng-repeat
         var compareDates = function(date) {
            var bits = date.split("/");
            return parseInt(bits[0]) + parseInt(bits[1]) * 30 +
                   parseInt(bits[2]) * 365;
        }
        
        $scope.compareDates = function(event) {
            return compareDates(event.start_date);
        }
                
        // Initializes collapsible behaviour
        $('.collapsible').collapsible({
            // Changes the collapsible behavior to expandable instead of the default accordion style
            accordion : false 
        });
        
        // Initialize calendar popup behaviour
        $('.datepicker').pickadate({
            // Creates a dropdown to control month and control year
            selectMonths: true, 
            selectYears: 15,
            format: 'dd/mm/yyyy',
            formatSubmit: 'dd/mm/yyyy'
        });
    }]);
}());
