angular.module('happyCow').controller('EventCtrl', [
  '$scope', '$location',
  function($scope, $location) {
    $scope.endPhase = function() {
      // change the location of the router
      $location.path('/phase/cards');
      // change the phase
      $scope.nextPhase();
    }
  }
]);
