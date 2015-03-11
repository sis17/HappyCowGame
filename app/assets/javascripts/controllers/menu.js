var menuCtrl = angular.module('happyCow').controller('MenuCtrl', [
  '$scope',
  function($scope) {
    return $scope;
  }
]);

menuCtrl.controller('ScoreViewCtrl', [
  '$scope',
  function($scope) {
  }
]);

menuCtrl.controller('RoundViewCtrl', [
  '$scope',
  function($scope) {
    
  }
]);

menuCtrl.controller('PlayerViewCtrl', [
  '$scope',
  function($scope) {
    //if ($scope.game.game_users[1]) {
    //  $scope.nextPlayer = $scope.game.game_users[1];
    //}
  }
]);
