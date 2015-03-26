angular.module('happyCow').controller('GameReviewCtrl', [
  '$scope', '$location', '$routeParams', 'Restangular',
  function($scope, $location, $routeParams, Restangular) {
    // get the game
    Restangular.one('games', $routeParams.gameId).get().then(function(game) {
      $scope.game = game;
    });
  }
]);
