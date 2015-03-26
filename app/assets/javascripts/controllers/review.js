angular.module('happyCow').controller('ReviewCtrl', [
  '$scope',
  function($scope) {
    $scope.$watch('game.stage', function(newValue, oldValue) {
      // to update the end of the round marker to be an end of the game marker
    });
  }
]);
