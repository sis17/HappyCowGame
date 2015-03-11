angular.module('happyCow').controller('EventCtrl', [
  '$scope', '$location',
  function($scope, $location) {
    $scope.goToCardsPhase = function() {
      $scope.game.round.eventReviewed = true;
      $scope.changePhaseTemplate(2);
    }
  }
]);
