angular.module('happyCow').controller('EventCtrl', [
  '$scope', '$location',
  function($scope, $location) {
    console.log($scope.game.round.current_phase);
  }
]);
