angular.module('happyCow').controller('ReviewCtrl', [
  '$scope', 'Action',
  function($scope, Action) {
    $scope.actions = Action.query();
  }
]);
