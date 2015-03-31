angular.module('happyCow').controller('ReviewCtrl', [
  '$scope',
  function($scope) {
    $scope.round = $scope.game.round;
    $scope.game_users = $scope.game.game_users;
    $scope.reviewDetailsTemplate = 'templates/partials/review_details.html';

    $scope.$watch('game.stage', function(newValue, oldValue) {
      // to update the end of the round marker to be an end of the game marker
      $scope.round = $scope.game.round;
      $scope.game_users = $scope.game.game_users;
    });
  }
]);
