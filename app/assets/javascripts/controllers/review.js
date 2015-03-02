angular.module('happyCow').controller('ReviewCtrl', [
  '$scope', 'User', 'Action', 'Record',
  function($scope, User, Action, Record) {
    $scope.actions = Action.query();
    $scope.users = User.query();
    $scope.records = Record.query();
  }
]);
