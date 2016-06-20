(function (){
    'use strict';
    var postr = angular.module('postr')

    postr.controller('postersCtrl', [
    '$scope',
    '$stateParams',
    'events',
    'posters',    
    function($scope, $stateParams, events, posters) {
        $scope.posters = posters;
        
        
        
        $scope.addPoster = function() {
            if(!$scope.title || $scope.title === '' ||
               !$scope.authors || $scope.authors === '') { 
                return; 
            }

            events.addPoster($stateParams.id, 
                             {title: $scope.title, 
                              authors: $scope.authors,
                              description: $scope.description, 
                              votes: 0}, 
                             $scope.posters);
            
            $scope.title = '';
            $scope.authors = '';
            $scope.description = '';
        };
        
        // Initializes collapsible behaviour
        $('.collapsible').collapsible({
            // Changes the collapsible behavior to expandable instead of the default accordion style
            accordion : false 
        });
        
        
        $("#ocrImageUpload").dropzone({ 
            url: '/events/' + $stateParams.id + '/findPoster',
            acceptedFiles: 'image/*', 
            // file size measured in MB 
            maxFilesize: 3, 
            dictDefaultMessage: 'Drag a poster image here to vote, or click to select one',
            init: function() {
                this.options.addRemoveLinks = true;
                this.options.dictRemoveFile = "Remove";
                
                // Process server response
                this.on('success', function(file, res) {
                    var msg = 'Voted for: ' + '\'' + res.title 
                              + '\'\n' + 'by ' + res.author;
                    
                    Materialize.toast(msg, 5000, 'rounded');
                  });
                
                // Show meter while sending file
                this.on("sending", function(file) {
                    $('.meter').show();
                });

                // Show progress while uploading file
                this.on("totaluploadprogress", function(progress) {
                    $('.roller').width(progress + '%');
                });
                
                this.on("queuecomplete", function(progress) {
                    $('.meter').delay(999).slideUp(999);
                });
            }
        });
    }]);
}());
