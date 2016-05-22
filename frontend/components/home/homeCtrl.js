(function (){
    'use strict';
    var postr = angular.module('postr')

    postr.controller('homeCtrl', [
    '$scope',
    '$http',
    function($scope, $http) {
        $('.slider').slider({full_width: true});
    }]);
}());
