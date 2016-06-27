(function (){
    'use strict';
    var postr = angular.module('postr')

    postr.controller('homeCtrl', [
    '$scope',
    '$state',
    '$http',  
    'authToken',    
    function($scope, $state, $http, authToken) {
        $scope.postrUser = {};
        
        $scope.loginToAccount = function() {
            // Make sure all fields all filled out.
            // If not prompt user
            if(!$scope.postrUser.username || $scope.postrUser.username === '' ||
               !$scope.postrUser.password || $scope.postrUser.password === '') { 
                Materialize.toast("Please fill out all fields", 5000, 'rounded');
                return; 
            }

            // Submit user credentials to be set in a post request
            authToken.loginToAccount($scope.postrUser).error(function(error) {
                 Materialize.toast(error.msg, 5000, 'rounded');
            }).then(function() {
                $state.go('events')
            });
            
            
        }
        
        $scope.registerAccount = function() {
            // Make sure all fields all filled out.
            // If not prompt user
            if(!$scope.postrUser.username || $scope.postrUser.username === '' ||
               !$scope.postrUser.password || $scope.postrUser.password === '') { 
                Materialize.toast("Please fill out all fields", 5000, 'rounded');
                return; 
            }
            
            // Submit user credentials to be set in a post request
            authToken.registerAccount($scope.postrUser).error(function(error) {
                 Materialize.toast(error.msg, 5000, 'rounded');
            }).then(function() {
                $state.go('events')
            });
        }
        
        $('.slider').slider({full_width: true});
    }]);
}());
