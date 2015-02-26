var menuCtrl = angular.module('happyCow').controller('MenuCtrl', [
  '$scope',
  function($scope) {
    return $scope;
  }
]);

menuCtrl.controller('ScoreViewCtrl', [
  '$scope', 'User',
  function($scope, User) {
    //$scope.players = User.query();
  }
]);

menuCtrl.controller('RoundViewCtrl', [
  '$scope', 'Round',
  function($scope, Round) {
    $scope.rounds = Round.query();

    $scope.roundIsActive = function(round) {
      return round.id == $scope.game.round.id;
    }
  }
]);

menuCtrl.controller('PlayerViewCtrl', [
  '$scope', 'User',
  function($scope, User) {
    $scope.players = User.query();
  }
]);
