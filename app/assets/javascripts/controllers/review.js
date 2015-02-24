angular.module('happyCow').controller('ReviewCtrl', [
  '$scope', '$location', 'User', 'Action', 'Record',
  function($scope,$location, User, Action, Record) {
    $scope.actions = Action.query();
    $scope.users = User.query();
    $scope.records = Record.query();

    $scope.endPhase = function() {
      // change the location of the router
      $location.path('/phase/event');
      // change the phase
      $scope.nextPhase();
    }
  }
]);
